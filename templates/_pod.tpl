{{- define "universal.pod" -}}
serviceAccountName: {{ .Values.app.serviceAccountName | default (include "universal.serviceAccountName" .) }}
{{- with .Values.app.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
tolerations:
  - key: node.kubernetes.io/not-ready
    effect: NoExecute
    tolerationSeconds: 0
  - key: node.kubernetes.io/unreachable
    effect: NoExecute
    tolerationSeconds: 0
{{- with .Values.app.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
shareProcessNamespace: {{ .Values.app.shareProcessNamespace }}
{{- if .Values.app.auth.enabled }}
volumes:
  - name: config
    configMap:
      name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-auth" }}
  - name: basic-auth-users
    secret:
      secretName: {{ .Values.app.auth.basicAuthSecret }}
      items:
        - key: users
          path: users
{{- end }}
containers:
  - name: {{ include "universal.fullname" . }}
    image: "{{ .Values.app.image.name }}:{{ .Values.app.image.tag }}"
    imagePullPolicy: {{ .Values.app.image.pullPolicy }}
    {{- with .Values.app.securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.commandArgs }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.ports }}
    ports:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.livenessProbe }}
    livenessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.readinessProbe }}
    readinessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.startupProbe }}
    startupProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.env }}
    env:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.envFrom }}
    envFrom:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.app.volumeMounts }}
    volumeMounts:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- with .Values.app.extraContainer }}
  - name: {{ .name }}
    image: "{{ .image.name }}:{{ .image.tag }}"
    imagePullPolicy: {{ .image.pullPolicy }}
    {{- with .securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .commandArgs }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .ports }}
    ports:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .livenessProbe }}
    livenessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .readinessProbe }}
    readinessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .env }}
    env:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .envFrom }}
    envFrom:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .volumeMounts }}
    volumeMounts:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- range .Values.app.sidecarContainers }}
  - name: {{ .name }}
    image: "{{ .image.name }}:{{ .image.tag }}"
    imagePullPolicy: {{ .image.pullPolicy }}
    {{- with .securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .commandArgs }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .ports }}
    ports:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .livenessProbe }}
    livenessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .readinessProbe }}
    readinessProbe:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .env }}
    env:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .envFrom }}
    envFrom:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .volumeMounts }}
    volumeMounts:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- if .Values.app.auth.enabled }}
  - name: nginx-auth
    image: nginx:{{ .Values.app.auth.nginxVer }}
    imagePullPolicy: IfNotPresent
    ports:
      - containerPort: {{ .Values.app.auth.nginxListenPort }}
        name: http
    volumeMounts:
      - name: config
        mountPath: /etc/nginx/conf.d/
        readOnly: true
      - name: basic-auth-users
        mountPath: /etc/nginx/conf.d/users
        readOnly: true
    resources:
      limits:
        cpu: {{ .Values.app.auth.resources.cpu }}
        memory: {{ .Values.app.auth.resources.memory }}
      requests:
        cpu: {{ .Values.app.auth.resources.cpu }}
        memory: {{ .Values.app.auth.resources.memory }}
  {{- end }}
{{- with .Values.app.volumes }}
volumes:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}