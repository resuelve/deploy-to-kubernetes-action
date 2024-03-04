# Deploy to kubernetes action

This action will run `kubectl` to update the given deployment container with a new image

## Inputs

| Input           | Required | Description                                                                                                              |
|-----------------|----------|--------------------------------------------------------------------------------------------------------------------------|
| cert            | yes      | base64 encoded certificate                                                                                               |
| server          | yes      | server host                                                                                                              |
| token           | yes      | authentication token                                                                                                     |
| namespace       | yes      | deployment's namespace to be updated                                                                                     |
| name            | yes      | deployment's name to be updated                                                                                          |
| image           | yes      | image name what will be used in the update, example: `org/repo:version`                                                  |
| container       | yes      | deployment's container which will be updated with new image                                                              |
| external_secret | no       | If defined, it will be forced to fetch latest values from secrets provider before the image is updated in the deployment |

## Usage

```yaml
- name: Update deployment container image
  uses: resuelve/deploy-to-kubernetes-action@v1.1
    with:
      cert: ${{ secrets.KUBERNETES_CERT }}
      server: ${{ secrets.KUBERNETES_SERVER }}
      token: ${{ secrets.KUBERNETES_TOKEN }}
      namespace: default
      name: my_project
      image: new_image_name
      container: backend
      external_secret: app-external-secret
```

Enjoy 🎉
