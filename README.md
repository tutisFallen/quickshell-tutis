# quickshell-tutis

Config inicial de Quickshell do Tutis.

## MVP atual
- Barra superior (`PanelWindow`) em todos os monitores
- Workspaces do Hyprland (clicáveis)
- Data + hora

## Estrutura
- `shell.qml` entrada principal
- `src/MainBar.qml` barra principal

## Rodar
```bash
quickshell -p ~/quickshell-tutis/shell.qml
```

## Próximos passos
- launcher estilo rofi/wofi (`PopupWindow`)
- widgets de áudio/rede/bateria/tray
- tema separado em módulos
