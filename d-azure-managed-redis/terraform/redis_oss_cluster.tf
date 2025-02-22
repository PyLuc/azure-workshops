resource "azapi_resource" "redis_clusteross" {
  type                      = "Microsoft.Cache/redisEnterprise@2024-09-01-preview"
  name                      = "redis-clusteross-${local.base_name}"
  parent_id                 = azurerm_resource_group.main.id
  location                  = azurerm_resource_group.main.location
  schema_validation_enabled = false
  body = {
    sku = {
      name = "ComputeOptimized_X10"
    }
    properties = {
      highAvailability = "Enabled"
    }
  }
}

resource "azapi_resource" "redis_clusteross_database" {
  type      = "Microsoft.Cache/redisEnterprise/databases@2024-09-01-preview"
  name      = "default"
  parent_id = azapi_resource.redis_clusteross.id
  body = {
    properties = {
      clientProtocol   = "Encrypted"
      evictionPolicy   = "NoEviction"
      clusteringPolicy = "OSSCluster" # OSSCluster or EnterpriseCluster
      deferUpgrade     = "NotDeferred"
      modules = [
        {
          name = "RedisJSON"
        },
        {
          name = "RedisBloom"
        },
        {
          name = "RedisTimeSeries"
        }
      ]
      persistence = {
        aofEnabled = false
        rdbEnabled = false
      }
      accessKeysAuthentication = "Enabled"
    }
  }
}

resource "azapi_resource" "redis_clusteross_access_self" {
  type      = "Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2024-09-01-preview"
  name      = "self"
  parent_id = azapi_resource.redis_clusteross_database.id
  body = {
    properties = {
      accessPolicyName = "default"
      user = {
        objectId = data.azurerm_client_config.current.object_id
      }
    }
  }
}


resource "azapi_resource" "redis_clusteross_access_app" {
  type      = "Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2024-09-01-preview"
  name      = "app"
  parent_id = azapi_resource.redis_clusteross_database.id
  body = {
    properties = {
      accessPolicyName = "default"
      user = {
        objectId = azurerm_user_assigned_identity.app.principal_id
      }
    }
  }
}
