#!/bin/bash
# =============================================================================
# Agent Zero - .env Update Script
# =============================================================================
#
# Dieses Script hilft Ihnen, die .env Datei zu aktualisieren und in den
# Docker-Container zu kopieren.
#
# Usage:
#   ./update-env.sh
#
# =============================================================================

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Container Name
CONTAINER_NAME="agent-zero-main"

# Pfade
HOST_ENV="./agent-zero-data/.env"
CONTAINER_ENV="/a0/.env"
EXAMPLE_ENV="./agent-zero-data/.env.example"

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Agent Zero - .env Konfiguration Update                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Prüfen ob Container läuft
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}✗ Fehler: Container '$CONTAINER_NAME' läuft nicht!${NC}"
    echo -e "${YELLOW}  Starten Sie den Container mit: docker start $CONTAINER_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Container '$CONTAINER_NAME' läuft${NC}"

# Prüfen ob .env Datei existiert
if [ ! -f "$HOST_ENV" ]; then
    echo -e "${YELLOW}⚠ .env Datei nicht gefunden auf Host-System${NC}"
    echo -e "${BLUE}→ Kopiere .env aus Container...${NC}"

    # Kopiere .env aus Container
    docker cp "$CONTAINER_NAME:$CONTAINER_ENV" "$HOST_ENV"

    if [ -f "$HOST_ENV" ]; then
        echo -e "${GREEN}✓ .env Datei erfolgreich kopiert${NC}"
        echo -e "${BLUE}  Pfad: $HOST_ENV${NC}"
    else
        echo -e "${RED}✗ Fehler beim Kopieren der .env Datei${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}Aktuelle .env Datei:${NC}"
echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
cat "$HOST_ENV"
echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
echo ""

# Frage Benutzer
echo -e "${BLUE}Was möchten Sie tun?${NC}"
echo ""
echo "  1) .env Datei bearbeiten (öffnet in Standard-Editor)"
echo "  2) .env Datei anzeigen"
echo "  3) API-Key hinzufügen (OpenAI)"
echo "  4) API-Key hinzufügen (Anthropic)"
echo "  5) API-Key hinzufügen (OpenRouter)"
echo "  6) .env in Container kopieren und neu starten"
echo "  7) .env.example anzeigen"
echo "  8) Abbrechen"
echo ""
read -p "Auswahl [1-8]: " choice

case $choice in
    1)
        echo -e "${BLUE}→ Öffne .env in Editor...${NC}"
        ${EDITOR:-nano} "$HOST_ENV"

        echo ""
        echo -e "${GREEN}✓ Datei wurde bearbeitet${NC}"
        echo ""
        read -p "Möchten Sie die .env jetzt in den Container kopieren? (j/n): " copy

        if [[ $copy == "j" || $copy == "J" || $copy == "y" || $copy == "Y" ]]; then
            echo -e "${BLUE}→ Kopiere .env in Container...${NC}"
            docker cp "$HOST_ENV" "$CONTAINER_NAME:$CONTAINER_ENV"
            echo -e "${GREEN}✓ .env Datei kopiert${NC}"

            echo -e "${BLUE}→ Starte Container neu...${NC}"
            docker restart "$CONTAINER_NAME"
            echo -e "${GREEN}✓ Container neu gestartet${NC}"
            echo ""
            echo -e "${GREEN}🎉 Konfiguration erfolgreich aktualisiert!${NC}"
            echo -e "${BLUE}   Öffnen Sie http://localhost:50080${NC}"
        fi
        ;;

    2)
        echo ""
        cat "$HOST_ENV"
        echo ""
        ;;

    3)
        echo ""
        read -p "OpenAI API-Key eingeben (sk-proj-...): " api_key

        if [[ -z "$api_key" ]]; then
            echo -e "${RED}✗ Kein API-Key eingegeben${NC}"
            exit 1
        fi

        # Prüfen ob OPENAI_API_KEY bereits existiert
        if grep -q "^OPENAI_API_KEY=" "$HOST_ENV"; then
            # Ersetze existierenden Key
            sed -i.bak "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$api_key|" "$HOST_ENV"
            echo -e "${GREEN}✓ OpenAI API-Key aktualisiert${NC}"
        else
            # Füge neuen Key hinzu
            echo "" >> "$HOST_ENV"
            echo "OPENAI_API_KEY=$api_key" >> "$HOST_ENV"
            echo -e "${GREEN}✓ OpenAI API-Key hinzugefügt${NC}"
        fi

        # Kopiere in Container
        docker cp "$HOST_ENV" "$CONTAINER_NAME:$CONTAINER_ENV"
        docker restart "$CONTAINER_NAME"
        echo -e "${GREEN}✓ Container neu gestartet${NC}"
        ;;

    4)
        echo ""
        read -p "Anthropic API-Key eingeben (sk-ant-...): " api_key

        if [[ -z "$api_key" ]]; then
            echo -e "${RED}✗ Kein API-Key eingegeben${NC}"
            exit 1
        fi

        if grep -q "^ANTHROPIC_API_KEY=" "$HOST_ENV"; then
            sed -i.bak "s|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=$api_key|" "$HOST_ENV"
            echo -e "${GREEN}✓ Anthropic API-Key aktualisiert${NC}"
        else
            echo "" >> "$HOST_ENV"
            echo "ANTHROPIC_API_KEY=$api_key" >> "$HOST_ENV"
            echo -e "${GREEN}✓ Anthropic API-Key hinzugefügt${NC}"
        fi

        docker cp "$HOST_ENV" "$CONTAINER_NAME:$CONTAINER_ENV"
        docker restart "$CONTAINER_NAME"
        echo -e "${GREEN}✓ Container neu gestartet${NC}"
        ;;

    5)
        echo ""
        read -p "OpenRouter API-Key eingeben (sk-or-...): " api_key

        if [[ -z "$api_key" ]]; then
            echo -e "${RED}✗ Kein API-Key eingegeben${NC}"
            exit 1
        fi

        if grep -q "^OPENROUTER_API_KEY=" "$HOST_ENV"; then
            sed -i.bak "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=$api_key|" "$HOST_ENV"
            echo -e "${GREEN}✓ OpenRouter API-Key aktualisiert${NC}"
        else
            echo "" >> "$HOST_ENV"
            echo "OPENROUTER_API_KEY=$api_key" >> "$HOST_ENV"
            echo -e "${GREEN}✓ OpenRouter API-Key hinzugefügt${NC}"
        fi

        docker cp "$HOST_ENV" "$CONTAINER_NAME:$CONTAINER_ENV"
        docker restart "$CONTAINER_NAME"
        echo -e "${GREEN}✓ Container neu gestartet${NC}"
        ;;

    6)
        echo ""
        echo -e "${BLUE}→ Kopiere .env in Container...${NC}"
        docker cp "$HOST_ENV" "$CONTAINER_NAME:$CONTAINER_ENV"
        echo -e "${GREEN}✓ .env Datei kopiert${NC}"

        echo -e "${BLUE}→ Starte Container neu...${NC}"
        docker restart "$CONTAINER_NAME"
        echo -e "${GREEN}✓ Container neu gestartet${NC}"
        echo ""
        echo -e "${GREEN}🎉 Konfiguration erfolgreich aktualisiert!${NC}"
        ;;

    7)
        if [ -f "$EXAMPLE_ENV" ]; then
            echo ""
            echo -e "${BLUE}.env.example Inhalt:${NC}"
            echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
            cat "$EXAMPLE_ENV"
            echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
        else
            echo -e "${RED}✗ .env.example nicht gefunden${NC}"
        fi
        ;;

    8)
        echo -e "${YELLOW}Abgebrochen${NC}"
        exit 0
        ;;

    *)
        echo -e "${RED}✗ Ungültige Auswahl${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Fertig!${NC}"
echo ""
echo -e "${BLUE}Nützliche Befehle:${NC}"
echo -e "  • Web-UI öffnen:      ${YELLOW}http://localhost:50080${NC}"
echo -e "  • Logs anschauen:     ${YELLOW}docker logs -f $CONTAINER_NAME${NC}"
echo -e "  • Container stoppen:  ${YELLOW}docker stop $CONTAINER_NAME${NC}"
echo -e "  • Container starten:  ${YELLOW}docker start $CONTAINER_NAME${NC}"
echo ""
