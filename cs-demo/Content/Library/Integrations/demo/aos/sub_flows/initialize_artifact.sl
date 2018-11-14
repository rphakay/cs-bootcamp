namespace: Integrations.demo.aos.sub_flows
flow:
  name: initialize_artifact
  inputs:
    - host: 10.0.46.85
    - username: root
    - password: admin@123
    - artifact_url:
        required: false
    - script_url: 'http://vmdocker.hcm.demo.local:36980/job/AOS-repo/ws/install_java.sh'
    - parameters:
        required: false
  workflow:
    - is_artifact_given:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${artifact_url}'
        navigate:
          - SUCCESS: copy_script
          - FAILURE: copy_artifact
    - copy_artifact:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - url: '${artifact_url}'
        publish:
          - artifact_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: copy_script
    - copy_script:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - url: '${script_url}'
        publish:
          - script_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: execute_artifact
    - execute_artifact:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && chmod 755 '+script_name+' && sh '+script_name+' '+get('artifact_name', '')+' '+get('parameters', '')+' > '+script_name+'.log'}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - command_return_code
        navigate:
          - SUCCESS: delete_script
          - FAILURE: delete_script
    - delete_script:
        do:
          Integrations.demo.aos.tools.delete_file:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - filename: '${script_name}'
        navigate:
          - SUCCESS: is_true
          - FAILURE: on_failure
    - is_true:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(command_return_code == '0')}"
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_artifact_given:
        x: 477
        y: 61
      copy_artifact:
        x: 201
        y: 237
      copy_script:
        x: 559
        y: 215
      execute_artifact:
        x: 417
        y: 407
      is_true:
        x: 752
        y: 507
        navigate:
          b1063740-ce9d-f145-b36e-16a1ce84867d:
            targetId: 004ef365-f1b6-1ad2-c3a8-1abcbe3b461d
            port: 'FALSE'
          ac0eaaeb-5359-35ed-f880-2657554d5bc0:
            targetId: a80948ea-1993-072f-01d7-073146acb4f8
            port: 'TRUE'
      delete_script:
        x: 634
        y: 382
    results:
      SUCCESS:
        a80948ea-1993-072f-01d7-073146acb4f8:
          x: 870
          y: 450
      FAILURE:
        004ef365-f1b6-1ad2-c3a8-1abcbe3b461d:
          x: 883
          y: 555
