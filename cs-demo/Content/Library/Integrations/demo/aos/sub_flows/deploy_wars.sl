namespace: Integrations.demo.aos.sub_flows
flow:
  name: deploy_wars
  inputs:
    - tomcat_host: 10.0.46.85
    - account_service_host: 10.0.46.85
    - db_host: 10.0.46.85
    - username: root
    - password: admin@123
    - url: "${get_sp('war_repo_root_url')}"
  workflow:
    - deploy_account_service:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - artifact_url: "${url+'accountservice/target/accountservice.war'}"
            - script_url: '${deploy_war.sh}'
            - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: deploy_tm_wars
    - deploy_tm_wars:
        loop:
          for: "war in 'catalog','MasterCredit','order','ROOT','ShipEx','SafePay'"
          do:
            Integrations.demo.aos.sub_flows.initialize_artifact:
              - host: '${tomcat_host}'
              - username: '${username}'
              - password: '${username}'
              - artifact_url: "${url+war.lower()+'/target/'+war+'.war'}"
              - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_account_service:
        x: 127
        y: 122
      deploy_tm_wars:
        x: 321
        y: 118
        navigate:
          9d40b4e8-ef4b-96f7-81df-7b52b4698f37:
            targetId: 10f2563b-bd5c-e7f3-28b4-8aa0671f8e27
            port: SUCCESS
    results:
      SUCCESS:
        10f2563b-bd5c-e7f3-28b4-8aa0671f8e27:
          x: 530
          y: 117
