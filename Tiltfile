load('ext://deployment', 'deployment_create')

k8s_yaml('deployments/tete-local-namespace.yml')

k8s_yaml('deployments/secrets.yml')

docker_build(
  'tete-web',
  '.',
  dockerfile='./Web.Dockerfile',
  # For a Dockerfile that has a 'COPY . /app' statement in it
  live_update=[sync('./Tete.Web', '/')]
)

deployment_create(
  'tete-web',
  namespace='tete-local',
  env_vars={
    'ConnectionStrings__DefaultConnection': {
      'valueFrom': {
        'secretKeyRef': {
          'name': 'db-credentials',
          'key': 'connection-string'
        }
      }
    },
    'ASPNETCORE_Kestrel__Certificates__Default__Password': {
      'valueFrom': {
        'secretKeyRef': {
          'name': 'cert-credentials', 
          'key': 'cert-password'
        }
      }
    }
  }
)

k8s_resource('tete-web', port_forwards=['8080:80', '8443:443'])

k8s_yaml('deployments/db-deployment.yml')

k8s_yaml('deployments/services.yml')

# Database initialization - runs after web service is ready
local_resource(
  'db-init',
  'curl -f http://localhost:8080/Init/Migrate && curl -f http://localhost:8080/Init/Populate',
  resource_deps=['tete-web'],
  labels=['database']
)

# Health check - manual trigger to verify system health
local_resource(
  'health-check',
  'curl -s http://localhost:8080/health | jq .',
  resource_deps=['tete-web'],
  auto_init=False,
  trigger_mode=TRIGGER_MODE_MANUAL,
  labels=['monitoring']
)
