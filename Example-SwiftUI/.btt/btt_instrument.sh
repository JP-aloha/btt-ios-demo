#!/bin/bash
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/opt/homebrew/bin"
if [[ -x "$SRCROOT/.btt/BTTInstrumentor" ]]; then
    "$SRCROOT/.btt/BTTInstrumentor" instrument "$SRCROOT" --non-interactive
elif [[ -x "$(command -v BTTInstrumentor)" ]]; then
    "$(command -v BTTInstrumentor)" instrument "$SRCROOT" --non-interactive
else
    exit 0
fi