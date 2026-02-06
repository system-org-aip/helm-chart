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
{{- with .Values.app.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .Values.app.hostNetwork }}
hostNetwork: true
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
{{- if or (.Values.secretDockerconfigjson.enabled) (.Values.app.imagePullSecrets) }}
imagePullSecrets:
{{- if .Values.secretDockerconfigjson.enabled }}
  - name: {{ include "universal.fullname" . }}-dockerconfigjson
{{- end }}
{{- with .Values.app.imagePullSecrets }}
  {{- toYaml . | nindent 2 }}
{{- end }}
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
    {{- if or .Values.app.env .Values.app.otel.enabled }}
    env:
    {{- if .Values.app.env }}
      {{- toYaml .Values.app.env | nindent 6 }}
    {{- end }}
    {{- if .Values.app.otel.enabled }}
      - name: OTEL_TRACES_EXPORTER
        value: "otlp"
      - name: OTEL_LOGS_EXPORTER
        value: "otlp"
      - name: OTEL_METRICS_EXPORTER
        value: "otlp"
      - name: OTEL_EXPORTER_OTLP_PROTOCOL
        value: "http/json"
      - name: OTEL_EXPORTER_OTLP_ENDPOINT
        value: {{ .Values.app.otel.exporter_url }}
      - name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
        value: "$(OTEL_EXPORTER_OTLP_ENDPOINT)/v1/traces"
      - name: OTEL_EXPORTER_OTLP_LOGS_ENDPOINT
        value: "$(OTEL_EXPORTER_OTLP_ENDPOINT)/v1/logs"
      - name: OTEL_EXPORTER_OTLP_METRICS_ENDPOINT
        value: "$(OTEL_EXPORTER_OTLP_ENDPOINT)/v1/metrics"
      - name: OTEL_TRACES_SAMPLER
        value: "always_on"
      - name: OTEL_LOGS_EXPORTER_OTLP_SPAN_CONTEXT
        value: "true"
      - name: OTEL_TRACES_EXPORTER_OTLP_SPAN_CONTEXT
        value: "true"
      - name: OTEL_NODE_RESOURCE_DETECTORS
        value: "env,host,os,serviceinstance"
      - name: OTEL_LOG_LEVEL
        value: {{ .Values.app.otel.log_level }}
    {{- end }}
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
    image: "{{ default $.Values.app.extraContainersList.image.name (.image).name }}:{{ default $.Values.app.extraContainersList.image.tag (.image).tag }}"
    imagePullPolicy: {{ default $.Values.app.extraContainersList.image.pullPolicy (.image).pullPolicy }}
    {{- with .securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if $.Values.app.extraContainersList.command }}
    {{- with $.Values.app.extraContainersList.command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    {{- with .command }}
    command:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- end  }}
    {{- if $.Values.app.extraContainersList.commandArgs }}
    {{- with $.Values.app.extraContainersList.commandArgs }}
    args:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    {{- with .commandArgs }}
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
    {{- with .lifecycle }}
    lifecycle:
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
