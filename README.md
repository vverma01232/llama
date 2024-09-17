# Deploying Ollama

This guide will walk you through deploying the Ollama application on Kubernetes and provides commands to interact with it.

## Prerequisites
- Kubernetes cluster is set up and `kubectl` is configured.

## Deployment Steps

1. **Create Namespace**: Apply the following YAML to create a namespace named `ollama`:
    ```bash
    kubectl apply -f <<CREATE_NAMESPACE_YAML>>
    ```
    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ollama
    ```

2. **Create Persistent Volume Claim (PVC)**: Apply the following YAML to create a PVC named `ollama-pvc` within the `ollama` namespace:
    ```bash
    kubectl apply -f <<CREATE_PVC_YAML>>
    ```
    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: ollama-pvc
      namespace: ollama
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 25Gi
    ```

3. **Deploy the Application**: Apply the following YAML to deploy the Ollama application:
    ```bash
    kubectl apply -f <<DEPLOYMENT_YAML>>
    ```
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ollama-deploy
      namespace: ollama
      labels:
        app: ollama
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: ollama
      template:
        metadata:
          labels:
            app: ollama
        spec:
          containers:
          - name: ollama
            image: ollama/ollama
            ports:
            - containerPort: 11434
            volumeMounts:
            - mountPath: /root/.ollama
              name: ollama-storage
          volumes:
          - name: ollama-storage
            persistentVolumeClaim:
              claimName: ollama-pvc
    ```

4. **Create Service**: Apply the following YAML to create a service for the Ollama application:
    ```bash
    kubectl apply -f <<SERVICE_YAML>>
    ```
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: ollama-svc
      namespace: ollama
    spec:
      selector:
        app: ollama
      ports:
      - protocol: TCP
        port: 11434
        targetPort: 11434
      type: LoadBalancer
    ```

5. **Access the Application**: The application is now deployed and accessible. To get the external IP of the service, run:
    ```bash
    kubectl get svc -n ollama
    ```

6. **Update Environment Variables**: Once you have the external IP, update the `OLLAMA_URL="http://<external_ip>:11434"` environment variable in your project with this IP.

## Interacting with the Application

To execute commands within the deployed Ollama application, follow these steps:

1. **Access Pod Terminal**: Execute the following command to access the terminal of any of the Ollama application pods:
    ```bash
    kubectl exec -it <PodName> -- bash
    ```
    Replace `<PodName>` with the name of the Ollama pod you want to access.

2. **Execute Ollama Commands**: Once inside the pod's terminal, you can execute Ollama commands. For example:
    ```bash
    ollama pull llama 3
    ```
    This command pulls the "llama" resource with a quantity of 3.
    ```bash
    ollama pull mistral
    ```
    This command pulls the "mistral" resource.
