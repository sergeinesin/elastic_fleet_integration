resource "elasticstack_fleet_agent_policy" "agent_policy" {
  name            = "azure-logs-agents"
  namespace       = "default"
}

data "elasticstack_fleet_integration" "azure" {
  name = "azure"
}

resource "elasticstack_fleet_integration" "azure_logs_integration" {
  name    = "azure"
  version = data.elasticstack_fleet_integration.azure.version
}

resource "elasticstack_fleet_integration_policy" "azure_logs" {
  name                = "azure-logs-${var.environment_name}"
  namespace           = "default"
  agent_policy_id     = elasticstack_fleet_agent_policy.agent_policy.policy_id
  integration_name    = elasticstack_fleet_integration.azure_logs_integration.name
  integration_version = elasticstack_fleet_integration.azure_logs_integration.version
  vars_json = jsonencode({
    "eventhub": "${var.eventhub_name}",
    "consumer_group": "$Default",
    "connection_string": "${var.eventhub_connection_string}",
    "storage_account": "${var.azurelogs_sa_name}",
    "storage_account_key": "${var.azurelogs_sa_accesskey}"
  })
  input {
      input_id = "eventhub-azure-eventhub"
      enabled = true
      streams_json = jsonencode({
            "azure.eventhub": {
                "enabled": true,
                "vars": {
                    "parse_message": true,
                    "preserve_original_event": true,
                    "data_stream.dataset": "azure.eventhub",
                    "tags": [
                        "azure-eventhub",
                        "forwarded"
                    ],
                    "sanitize_newlines": false,
                    "sanitize_singlequotes": false
                }
            }  
    })                                          
  }
}
