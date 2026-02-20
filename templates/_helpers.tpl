{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "universal.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "universal.fullname" -}}
{{- if .Values.global.fullnameOverride }}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.global.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "universal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "universal.namespace" -}}
{{- if .Values.global.namespaceOverride }}
{{- .Values.global.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "universal.labels" -}}
helm.sh/chart: {{ include "universal.chart" . }}
{{ include "universal.selectorLabels" . }}
{{- if or .Chart.AppVersion .Values.app.image.tag }}
app.kubernetes.io/version: {{ mustRegexReplaceAllLiteral "@sha.*" .Values.app.image.tag "" | default .Chart.AppVersion | trunc 63 | trimSuffix "-" | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "universal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "universal.namespace" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account
*/}}
{{- define "universal.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "universal.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the configmap
*/}}
{{- define "universal.configMapName" -}}
{{- if and .Values.configmap.name ( not .Values.configmap.nameSuffix ) }}
{{- .Values.configmap.name }}
{{- else if and .Values.configmap.name .Values.configmap.nameSuffix }}
{{- printf "%s-%s" .Values.configmap.name .Values.configmap.nameSuffix }}
{{- else if and ( not .Values.configmap.name ) .Values.configmap.nameSuffix }}
{{- printf "%s-%s" ( include "universal.fullname" $ ) .Values.configmap.nameSuffix }}
{{- else }}
{{- include "universal.fullname" $ }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret
*/}}
{{- define "universal.secretName" -}}
{{- if and .Values.secret.name ( not .Values.secret.nameSuffix ) }}
{{- .Values.secret.name }}
{{- else if and .Values.secret.name .Values.secret.nameSuffix }}
{{- printf "%s-%s" .Values.secret.name .Values.secret.nameSuffix }}
{{- else if and ( not .Values.secret.name ) .Values.secret.nameSuffix }}
{{- printf "%s-%s" ( include "universal.fullname" $ ) .Values.secret.nameSuffix }}
{{- else }}
{{- include "universal.fullname" $ }}
{{- end }}
{{- end }}

{{/*
Create the name of the pvc
*/}}
{{- define "universal.pvcName" -}}
{{- if and .Values.pvc.name ( not .Values.pvc.nameSuffix ) }}
{{- .Values.pvc.name }}
{{- else if and .Values.pvc.name .Values.pvc.nameSuffix }}
{{- printf "%s-%s" .Values.pvc.name .Values.pvc.nameSuffix }}
{{- else if and ( not .Values.pvc.name ) .Values.pvc.nameSuffix }}
{{- printf "%s-%s" ( include "universal.fullname" $ ) .Values.pvc.nameSuffix }}
{{- else }}
{{- include "universal.fullname" $ }}
{{- end }}
{{- end }}

{{/*
Create probes
*/}}
{{- define "universal.probe" -}}
{{- $context := index . 0 -}} {{/* Global context ($) */}}
{{- $probe := index . 1 -}} {{/* Probes context */}}
{{- if or $probe.path $probe.tcpPort $probe.grpcPort $probe.command $probe.custom }}
{{- if $probe.custom -}}
{{- toYaml $probe.custom | nindent 2 }}
{{- else }}
{{- if $probe.path -}}
httpGet:
  path: {{ $probe.path }}
  port: {{ $probe.port | default $context.Values.app.commonPort }}
  scheme: {{ $probe.scheme | default "HTTP" }}
{{- else if $probe.tcpPort -}}
tcpSocket:
  port: {{ $probe.tcpPort | default $context.Values.app.commonPort }}
{{- else if $probe.grpcPort -}}
grpc:
  port: {{ $probe.grpcPort | default $context.Values.app.commonPort }}
{{- else if $probe.command -}}
exec:
  command: {{ toYaml $probe.command | nindent 4 }}
{{- end }}
{{- with $probe.initialDelaySeconds }}
initialDelaySeconds: {{ . }}
{{- end }}
{{- with $probe.periodSeconds }}
periodSeconds: {{ . }}
{{- end }}
{{- with $probe.timeoutSeconds }}
timeoutSeconds: {{ . }}
{{- end }}
{{- with $probe.successThreshold }}
successThreshold: {{ . }}
{{- end }}
{{- with $probe.failureThreshold }}
failureThreshold: {{ . }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
