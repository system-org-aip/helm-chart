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
{{- if or .Values.app.auth.enabled .Values.app.volumes .Values.configmap.createVolume }}
volumes:
{{- with .Values.app.volumes }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .Values.app.auth.enabled }}
  - name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-conf" }}
    configMap:
      name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-conf" }}
  - name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-auth-users" }}
    secret:
      secretName: {{ .Values.app.auth.basicAuthSecret }}
{{- end }}
{{- if .Values.configmap.createVolume }}
  - name: {{ include "universal.configMapName" . }}
    configMap:
      name: {{ include "universal.configMapName" . }}
{{- end }}
{{- end }}
{{- if .Values.secretDockerconfigjson.enabled }}
imagePullSecrets:
  - name: {{ include "universal.fullname" . }}-dockerconfigjson
{{- end }}
containers:
  - name: {{ include "universal.fullname" . }}
    image: "{{ .Values.app.image.name }}{{ if .Values.app.image.tag }}:{{ .Values.app.image.tag }}{{ end }}"
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
    image: "{{ .image.name }}{{ if .image.tag }}:{{ .image.tag }}{{ end }}"
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
  {{- if .Values.app.extraContainersList.list  }}
  {{- range .Values.app.extraContainersList.list }}
  - name: {{ .name }}
    image: "{{if $.Values.app.extraContainersList.image.name }}{{ $.Values.app.extraContainersList.image.name }}{{ else }}{{ .image.name }}{{ if .image.tag }}:{{ .image.tag }}{{ end }}{{ end }}"
    imagePullPolicy: {{ if $.Values.app.extraContainersList.image.pullPolicy }}{{ $.Values.app.extraContainersList.image.pullPolicy }}{{ else }}{{ .image.pullPolicy }}{{ end }}
    {{- with .securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if $.Values.app.extraContainersList.args }}
    {{- with $.Values.app.extraContainersList.args }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    {{- with .args }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- end  }}
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
    {{- if $.Values.app.extraContainersList.resources }}
    {{- with $.Values.app.extraContainersList.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    {{- with .resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- end  }}
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
  {{- end }}
  {{- range .Values.app.sidecarContainers }}
  - name: {{ .name }}
    image: "{{ .image.name }}{{ if .image.tag }}:{{ .image.tag }}{{ end }}"
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
      - name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-conf" }}
        mountPath: /etc/nginx/conf.d/default.conf
        subPath: default.conf
        readOnly: true
      - name: {{ printf "%s-%s" ( include "universal.fullname" . ) "nginx-auth-users" }}
        mountPath: /etc/nginx/conf.d/users
        subPath: users
        readOnly: true
    resources:
      limits:
        cpu: {{ .Values.app.auth.resources.cpu }}
        memory: {{ .Values.app.auth.resources.memory }}
      requests:
        cpu: {{ .Values.app.auth.resources.cpu }}
        memory: {{ .Values.app.auth.resources.memory }}
  {{- end }}
{{- end }}
