{{/*
Expand the name of the chart.
*/}}
{{- define "fabric-operator-hlf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fabric-operator-hlf.fullname" -}}
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
{{- define "fabric-operator-hlf.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fabric-operator-hlf.labels" -}}
helm.sh/chart: {{ include "fabric-operator-hlf.chart" . }}
{{ include "fabric-operator-hlf.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fabric-operator-hlf.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fabric-operator-hlf.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fabric-operator-hlf.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fabric-operator-hlf.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "fabric-operator-hlf.caCert" -}}
    {{- if .caConnectionProfileConfig }}
      {{- $cpMap := split "/" .caConnectionProfileConfig }}
      {{- $cpData := (lookup "v1" "ConfigMap" $cpMap._0 $cpMap._1).binaryData }}
      {{- if $cpData }}
        {{- $profile := (index $cpData "profile.json") | b64dec | fromJson }}
        {{- $profile.tls.cert }} 
      {{- end }}
    {{- else }}
     {{ "" }}
    {{- end }}
{{- end }}

{{- define "fabric-operator-hlf.caHost" -}}
  {{- if .caConnectionProfileConfig }}
      {{- $cpMap := split "/" .caConnectionProfileConfig }}
      {{- $cpData :=  (lookup "v1" "ConfigMap" $cpMap._0 $cpMap._1).binaryData }}
      {{- if $cpData }}
        {{- $profile := (index $cpData "profile.json") | b64dec | fromJson }}
        {{- $endpoint := $profile.endpoints.api | split "/"  }}
        {{- (split ":" $endpoint._2)._0 }}
      {{- end }}
    {{- else }}
      {{ "" }}
    {{- end }}
{{- end }}

{{- define "fabric-operator-hlf.caPort" -}}
  {{- if .caConnectionProfileConfig }}
      {{- $cpMap := split "/" .caConnectionProfileConfig }}
      {{- $cpData :=  (lookup "v1" "ConfigMap" $cpMap._0 $cpMap._1).binaryData }}
      {{- if $cpData }}
        {{- $profile := (index $cpData "profile.json") | b64dec | fromJson }}
        {{- $endpoint := $profile.endpoints.api | split "/" }}
        {{- (split ":" $endpoint._2)._1 }}
      {{- end }}
    {{- else }}
      {{ "" }}
    {{- end }}
{{- end }}

{{- define "fabric-operator-hlf.getOrg" -}}
  {{- $org := dict }}
  {{- $orgName := .orgName }}
  {{- range $o := .Values.orgs }}
    {{- if eq $o.name $orgName }}
      {{- $org = $o }}
    {{- end }}
  {{- end }}
  {{- $org | toYaml }}
{{- end }}

{{- define "fabric-operator-hlf.getOrderer" -}}
  {{- $orderer := dict }}
  {{- $orderers := .orderers -}}
  {{- $ordererName := .ordererName }}
  {{- range $o := $orderers }}
    {{- if eq (toString $o.name) $ordererName }}
      {{- $orderer = $o }}
    {{- end }}
  {{- end}}
  {{- $orderer | toYaml }}
{{- end }}

{{- define "fabric-operator-hlf.getChannelPeerOrgs" -}}
  {{ $newList := list }}
  {{- $channelOrgs := .orgs }}
  {{- range $o := $channelOrgs }}
    {{- if ($o.peers).enabled }}
      {{ $newList := append $newList $o }}
    {{- end }}
  {{- end}}
  {{- $newList | toYaml }}
{{- end }}

{{- define "fabric-operator-hlf.getChannelOrdererOrgs" -}}
  {{ $newList := list }}
  {{- $channelOrgs := .orgs }}
  {{- range $o := $channelOrgs }}
    {{- if ($o.orderers).enabled }}
      {{ $newList := append $newList $o }}
    {{- end }}
  {{- end}}
  {{- $newList | toYaml }}
{{- end }}