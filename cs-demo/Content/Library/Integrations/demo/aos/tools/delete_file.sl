namespace: Integrations.demo.aos.tools
flow:
  name: delete_file
  inputs:
    - host
    - username
    - password
    - filename
  workflow:
    - delete_file:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && rm -f '+filename}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      delete_file:
        x: 57
        y: 176
        navigate:
          1997a8af-f3a7-3cd2-fa6c-69004b55f24d:
            targetId: c8ce62aa-b7dc-9488-e226-794cf46262a4
            port: SUCCESS
    results:
      SUCCESS:
        c8ce62aa-b7dc-9488-e226-794cf46262a4:
          x: 289
          y: 165
