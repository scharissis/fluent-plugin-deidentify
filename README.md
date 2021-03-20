# fluent-plugin-deidentify

[Fluentd](https://fluentd.org/) filter plugin to deidentify sensitive information in logs.
It has been built with JSON input in mind.

## Installation

https://docs.fluentd.org/v/0.12/developer/plugin-development#installing-custom-plugins

## Configuration

Three optional top-level configuration parameters exist:
* Remover (removes k-v pairs)
* Masker (masks values)
* Replacer (replaces values)


### Remover

Remover removes an entire key-value pair from a log, if the value is a string.
Nested keys are supported with the syntax "parent.child".

**Example**

Config:

```
<remover>
  paths ["email", "config.url"]
</remover>
```

Input:

```
{"email": "user@address.com", "config": {"darkMode": "true", "url": "user.com"}}
```

Output:

```
{"config": {"darkMode": "true"}}
```

### Masker

Masker 'masks' values at a particular path with a replacement string.

**Example:**

Config:

```
<masker>
  paths ["email", "config.url"]
  mask "*****"
</masker>
```

Input:

```
{"email": "user@address.com", "config": {"darkMode": "true", "url": "user.com"}}
```

Output:

```
{"email": "*****", "config": {"darkMode": "true", "url": "*****"}}
```

### Replacer

Replacer replaces matching values with replacement strings.
Multiple \<replacer\> blocks may be provided.

**Example:**

Config:

```
<replacer>
  regex "/users/\d+"
  replacement "/users/{id}"
</replacer>

<replacer>
  regex "female"
  replacement "<redacted>"
</replacer>
```

Input:

```
{"userPath": "/users/42", "userInfo": {"sex": "female"}}
```

Output:

```
{"userPath": "/users/{id}", "userInfo": {"sex": "<redacted>"}}
```

### Complete Config Example

```
<filter *>
  @type deidentify

  <masker>
    paths ["labels.color"]
    mask  'REDACTED'
  </masker>

  <remover>
    paths ["labels.height"]
  </remover>

  <replacer>
    regex '\/secrets\/(\d+)'
    replacement '/secrets/{id}'
  </replacer>

  <replacer>
    regex 'sensitive'
    replacement '<sensitive>'
  </replacer>

</filter>
```

## Copyright

* Copyright(c) 2021- Stefano Charissis
* License
  * MIT
