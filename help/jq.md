# The tutorial (from https://mosermichael.github.io/jq-illustrated/dir/content.html)

## Get a single scalar values

```
cat s1.json | jq ' .spec.replicas '
```

## Get a single scalar values (different form, as a pipeline)

```
cat s1.json | jq ' .spec | .replicas '
```

## Get two scalar values

```
cat s1.json | jq ' .spec.replicas, .kind '
```

## Get two scalar values and concatenate/format them into a single string

```
cat s1.json | jq ' "replicas: " + (.spec.replicas | tostring) + " kind: " + .kind '
```

## Select an object from an array of object based on one of the names

```
cat dep.json | jq ' .status.conditions | map(select(.type == "Progressing")) '
```

## Select a single key value pair from a json object

```
cat ann.json | jq ' .metadata.annotations | to_entries | map(select(.key == "label1")) | from_entries '
```

## Select two key value pairs from a json object

```
cat ann.json | jq ' .metadata.annotations | to_entries | map(select(.key == "label1" or .key == "label2")) | from_entries '
```

## Select two key value pairs from a json object (second version)

```
cat ann.json | jq ' .metadata.annotations | to_entries | map(select(.key == ("label1", "label2"))) | from_entries '
```

## Select all key value pairs from a json object where the name contains substring "label"

```
cat ann.json | jq ' .metadata.annotations | to_entries | map(select(.key | contains("label"))) | from_entries '
```

## Select all key value pairs from a json object where the name matches the regular expression label[1-9]

```
cat ann.json | jq ' .metadata.annotations | to_entries | map(select(.key | test("label[1-9]"))) | from_entries '
```

## Add another key value pair to a json object

```
cat ann.json | jq ' .metadata.annotations += { "label4" : "two" } '
```

## Set all values in a json object

```
cat ann.json | jq ' .metadata.annotations | to_entries | map_values(.value="override-value") | from_entries '
```
