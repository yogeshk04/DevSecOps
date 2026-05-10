{{/*
Expand the name of the chart.
*/}}
{{- define "dso-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dso-helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "dso-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dso-helm.labels" -}}
helm.sh/chart: {{ include "dso-helm.chart" . }}
{{ include "dso-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dso-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dso-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dso-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dso-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* ============================================================
     DSO component name helpers
     ============================================================ */}}

{{- define "dso.db.name" -}}
{{- printf "%s-db" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dso.backend.name" -}}
{{- printf "%s-backend" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dso.frontend.name" -}}
{{- printf "%s-frontend" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dso.secret.name" -}}
{{- printf "%s-db-secret" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dso.pv.name" -}}
{{- printf "%s-db-pv" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dso.pvc.name" -}}
{{- printf "%s-db-pvc" (include "dso-helm.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common part-of label */}}
{{- define "dso.partOf" -}}
app.kubernetes.io/part-of: {{ include "dso-helm.name" . }}
{{- end }}
