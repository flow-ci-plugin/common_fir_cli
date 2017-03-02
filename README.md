# fir-cli Step
fir-cli tool, which could upload your app to fir.im.

### INPUTS

* `FLOW_FIR_API_TOKEN` - fir.im api token.
* `FLOW_FIR_CHANGELOG` - changelog.
* `FLOW_FIR_APP_PATH` - app absolute path.


## EXAMPLE 

```yml
steps:
  - name: fir-cli
    enable: true
    failure: true
    plugin:
      name: fir_plugin
      inputs:
        - FIR_API_TOKEN=$FLOW_FIR_API_TOKEN
        - FIR_CHANGELOG=$FLOW_FIR_CHANGELOG
        - FIR_APP_PATH=$FLOW_FIR_APP_PATH
```
