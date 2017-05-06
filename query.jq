#!/usr/bin/env jq -Mf
def get_tag(name): (
    # Wrapping in an array means that if there is no matching tag (or no tags
    # at all) then we return null instead of not returning anything, which
    # would filter the object out.
    # There may be a better way to do this.
    [
        select(.Tags != null) |
        .Tags[] |
        select(.Key == name) |
        .Value
    ][0]
);

def get_instance_name:
    # Return the instance name, or the instance ID if the instance has no name
    get_tag("Name") // .InstanceId;

def tag_filter(name; value):
    get_tag(name) // "" | contains(value);

def instance_id_filter(value):
    .InstanceId | startswith(value);

def filter(value):
    # TODO - arbitrary tag filtering: tagname:value
    if (value | startswith("i-")) then
        instance_id_filter(value)
    else
        tag_filter("Name"; value)
    end;

def multi_word_filter(query):
    # Splits up the query into individual words, runs the filter on all words,
    # and selects the item only if all other filters match.
    # Note: child filters return true or false and don't run select themselves.
    select([(query | split(" "))[] as $value | filter($value)] | all);

def alfred_item:
    {
        title: get_instance_name,
        subtitle: .PrivateIpAddress,
        arg: .PrivateIpAddress,
        mods: {
            cmd: {
                subtitle: .InstanceId,
                arg: .InstanceId
            },
            alt: {
                subtitle: .PublicIpAddress,
                arg: .PublicIpAddress
            }
        }
    };


{items: [.Reservations[].Instances[] | multi_word_filter($query) | alfred_item]}
