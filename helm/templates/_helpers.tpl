{{/*
Expand the name of the chart.
*/}}
{{- define "devsecops.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this.
*/}}
{{- define "devsecops.fullname" -}}
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
Chart label value: <name>-<version>
*/}}
{{- define "devsecops.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "devsecops.labels" -}}
helm.sh/chart: {{ include "devsecops.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Fully qualified names for each component (used in Service names & env vars).
*/}}
{{- define "devsecops.db.fullname" -}}
{{- printf "%s-db" (include "devsecops.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "devsecops.backend.fullname" -}}
{{- printf "%s-backend" (include "devsecops.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "devsecops.frontend.fullname" -}}
{{- printf "%s-frontend" (include "devsecops.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name of the Secret that holds DB credentials.
*/}}
{{- define "devsecops.secret.name" -}}
{{- printf "%s-db-secret" (include "devsecops.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
