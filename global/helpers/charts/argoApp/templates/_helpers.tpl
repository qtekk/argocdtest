{{- define "argoApps.create" -}}
{{- range .Values.apps }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ $.Values.project }}-{{ .name }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: {{ .namespace }}
    server: {{ $.Values.destination.server }}
  project: {{ $.Values.project }}
  syncPolicy:
    {{- if eq .syncPolicy "auto" }}
    automated:
      selfHeal: true
    {{- end }}
    syncOptions:
      - CreateNamespace=true
      - RespectIgnoreDifferences=true
  sources:
  {{- if .chart }}
    - repoURL: {{ .chart.repoURL }}
      targetRevision: {{ .chart.targetRevision }}
      chart: {{ .chart.name }}
      helm:
      {{- if .chart.values }}
        valueFiles:
        {{- range $path := .chart.values.paths }}
          - {{ if hasPrefix "common/" $path }}
              $values/{{$path }}
            {{ else }}
              $values/environments/{{ $.Values.env }}/{{ $.Values.app }}/{{$path }}
            {{ end }}
        {{- end }}
      {{- end }}
    {{- if .chart.values }}
    - repoURL: {{ $.Values.repoURL }}
      targetRevision: {{ .chart.values.targetRevision }}
      ref: values
    {{- end }}
  {{- end }}
  {{- if .manifest}}
    - repoURL: {{ $.Values.repoURL }}
      targetRevision: {{ .manifest.targetRevision }}
      path: environments/{{ $.Values.env }}/{{ $.Values.app }}/{{ .manifest.path }}
  {{- end }}
  {{- if .ignoreDifferences }}
  ignoreDifferences:
    {{- .ignoreDifferences | toYaml | trim | nindent 4}}
  {{- end }}
---
{{- end }}
{{- end }}
