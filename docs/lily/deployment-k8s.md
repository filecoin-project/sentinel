# Lily deployment: Kubernetes

The Sentinel team operates a production deployment of Lily using Kubernetes
and maintain Helm charts for it. This guide provides an overview on how to
achieve the same.

[Helm charts for Lily are available](https://github.com/filecoin-project/helm-charts/)
for ease of deployment. The following steps will use helm to deploy Lily to an
existing Kubernetes cluster.

We assume users are already familiar with the basic operation of
[Helm](https://helm.sh/docs/intro/install/) and
[Kubernetes clusters](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/).

* [Helm deployment](#helm-deployment)
* [Upgrades](#upgrades)
* [Controlling Helm chart versions used in deployment](#controlling-helm-chart-versions-used-in-deployment)
* [Troubleshooting](#troubleshooting)

---

## Helm deployment

1. Add Filecoin helm charts repo.
    ```
    $ helm repo add filecoin https://filecoin-project.github.io/helm-charts
    ```

2. Copy default values YAML out of the Helm chart into a new `values.yaml`
   file to use locally for your deployment and adjust the values to meet the
   needs of your deployment.

3. If needed, set up the database credentials. They must be provided in a
   `secret` within the cluster. The `<deployed_secret_name>` is the key which
   is referred to in `custom-values.yaml`.
    ```
    # export the following envvars (whose names have no significance other 
    # than to indicate their placement in the `kubectl` and `helm` commands below)
    KUBE_CONTEXT=<kube_context> # otherwise as inferred by kubectl
    KUBE_NAMESPACE=<kube_namespace> # otherwise as inferred by kubectl
    LILY_SECRET_NAME=<deployed_secret_name>
    LILY_SECRET_HOST=<resolveable_hostname>
    LILY_SECRET_PORT=<port>
    LILY_SECRET_DATABASE=<database_name>
    LILY_SECRET_USER=<username>
    LILY_SECRET_PASS=<password>

    # create the secret
    $ kubectl create secret generic \
        --context="$(KUBE_CONTEXT)" \
        --namespace "$(KUBE_NAMESPACE)" \
        "$(LILY_SECRET_NAME)" \
        --from-literal=url="postgres://$(LILY_SECRET_USER):$(LILY_SECRET_PASS)@$(LILY_SECRET_HOST):$(LILY_SECRET_PORT)/$(LILY_SECRET_DATABASE)?sslmode=require"
    ```
    Be sure to configure your `custom-values.yaml` with the `<deployed_secret_name>` like so:
    ```
    ...
    storage:
        postgresql:
        - name: db
          secretName: <deployed_secret_name> # <- goes here
          secretKey: url
          schema: lily
          applicationName: lily
    ...
    ```

4. Deploy your release with `helm install`. (Make sure you are using the right
   kubernetes context for your intended cluster.) The following example uses
   `helm upgrade --install` which universally works for `install` and
   `upgrade` (change-in-place) operations.
    ```
    $ helm upgrade --install \
                   --kube-context="$(KUBE_CONTEXT)" \
                   --namespace="$(KUBE_NAMESPACE)" \
                   $(RELEASE_NAME) filecoin/lily -f ./custom-values.yaml
    ```

    NOTE: The flags `--wait` and `--timeout` can be added to make this a
    blocking request, instead of returning immediately after successful delivery
    of the install/upgrade request.

5. Monitor the deployment of your release.
    ```
    # get logs of Lily container
    $ export CONTAINER_NAME=daemon

    $ kubectl --context="$(KUBE_CONTEXT)" \
              --namespace="$(KUBE_NAMESPACE)" logs $(RELEASE_NAME)-lily-0 $(CONTAINER_NAME) \
              --follow

    # get interactive shell in Visor container
    $ kubectl --context="$(KUBE_CONTEXT) \
              --namespace="$(KUBE_NAMESPACE)" \
              exec -it $(RELEASE_NAME)-lily-0 $(CONTAINER_NAME) -- bash
    ```


---

## Upgrades

You can update the `custom-values.yaml` file and deploy changes with:

```
# same helm upgrade --install command as before
$ helm upgrade \
    --install \
    --kube-context="$(KUBE_CONTEXT)" \
	--namespace="$(KUBE_NAMESPACE)" \
	$(RELEASE_NAME) filecoin/lily -f custom-values.yaml
```

---

## Controlling Helm chart versions used in deployment

If you want to control the specific version of Helm chart used, a `--version`
flag may be passed into `helm upgrade|install`:

```
$ helm upgrade --install $(RELEASE_NAME) filecoin/lily --version "M.N.R"
```

Omitting `--version` argument will use the latest available version.

---

## Troubleshooting

### deployment error: "N node(s) had volume node affinity conflict"

Background: Sentinel Visor has Persistent Volume Claims (PVC) which are lazily
assigned as they bound to the pod they are requested from. When a release has
been destroyed without cleaning these lazily created PVC or an upgrade causes
a pod to be assigned to a new node (different from what it was previously
scheduled) the existing PVC can cause the deployment to become stuck.

To resolve:

1. Describe the pod which is having the schedule confict to identify the PVC name it is bound to. _(Note: Assuming your release name is `analysis`.)

    ```
    kubectl describe pod <releasename>-visor-0
    ```

    Example:

    ```
    $ kubectl describe pod analysis-visor-0
    Volumes:
        datastore-volume:
        Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
        ClaimName:  datastore-volume-analysis-visor-0
        ReadOnly:   false
	```

2. Delete the PVC.

   ```
   kubectl delete pvc datastore-volume-<releasename>-visor-0
   ```

    Example:

    ```
    $ kubectl delete pvc datastore-volume-analysis-visor-0
    persistentvolumeclaim "datastore-volume-analysis-visor-1" deleted
    ```

3. Restart the pod.

    ```
    kubectl delete pod <releasename>-visor-0
    ```

    Example:

    ```
    $ kubectl delete pod analysis-visor-0
    pod "analysis-visor-1" deleted
    ```

### deployment error: Multi-Attach error for volume "XXX"

Background: Deployment is in progress and the new pod attempts to start up but
blocks with the error "Multi-Attach error for volume
"pvc-a41e35bd-d1dc-11e8-9b2b-fa163ef89d28" Volume is already exclusively
attached to one node and can't be attached to another." This is likely a
timing issue where termination of a pod on one node has not allowed the volume
to be released before the scheduling and spin-up of the replacement pod on a
different node. The quickest fix is to delete the pod and allow the
StatefulSet to restore the pod and be able to bind the volume to the new node.

To resolve:

1. Delete the pod and wait for the scheduler to start it again. Generally, it only takes a little time for the volume to release.

    ```
    $ kubectl delete pod <releasename>-visor-<N>
    ```

    Example:

    ```
    $ kubectl delete pod analysis-visor-1
    pod "analysis-visor-1" deleted
    ```

2. Observe the pod being rescheduled and the volume properly attaching to the new node.
