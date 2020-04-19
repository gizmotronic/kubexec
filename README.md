# Kubernetes Pod Executor

This image is a trivial wrapper around [bitnami/kubectl](https://bitnami.com/stack/kubectl/containers) which simplifies the task of running [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) targeting specific workloads in a Kubernetes cluster. This is particularly useful for Deployments, which use ephemeral pod names.

*This image exists solely to assist with the migration of legacy applications into a Kubernetes cluster. It should not be used with a properly designed cluster-native application.*

## Usage

When executed, the image creates a [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file to access the cluster that the job is scheduled to run on.

The entrypoint script interprets the first argument of the provided command line as a [grep](http://linuxcommand.org/lc3_man_pages/grep1.html) pattern used to filter actively running pods by name. The first pod returned will be used as the target to run the job. The rest of the command line is passed as-is to `kubectl exec`.

### Limitations

The entrypoint script makes these assumptions:

- The target pod is in the same cluster and namespace as the job; and
- The service account associated with the job has been [granted permission](#configuring-permissions) to execute arbitary commands in the target pod.

### Examples

To run a simple command in the first pod with a name starting with `mypod-`:

```shell
^mypod- node cleanuptask.js
```

Because the comnand line after the first argument is passed as-is to `kubectl exec`, you may find that arguments to your command are interpreted by `kubectl` instead of your command. To resolve this, use `--` to indicate that anything further should be passed to the target command:

```shell
^mypod- -- rm -f /tmp/myapp_*
```

## Configuring permissions

If your cluster uses [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) you will need configure access for the service account to list pods and execute commands. Modify the following YAML object, replacing the target namespace and, if necessary, the service account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-exec
  namespace: targetnamespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-exec
  namespace: targetnamespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-exec
subjects:
- kind: ServiceAccount
  name: default
  namespace: targetnamespace
```

Use `kubectl apply` with the resulting object to configure the changes.