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
  namespace='tete-local'
)

k8s_resource('tete-web', port_forwards=['8080:80', '8443:443'])

k8s_yaml('deployments/db-deployment.yml')

k8s_yaml('deployments/services.yml')
