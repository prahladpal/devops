apiVersion: apps/v1
kind: Deployment
metadata:
  name: ace-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ace-server
  template:
    metadata:
      labels:
        app: ace-server
    spec:
      containers:
      - name: ace
        image: prahladpal/ace13:v1
        ports:
        - containerPort: 4414
        env:
        - name: LICENSE
          value: accept
        - name: ACE_SERVER_NAME
          value: default
