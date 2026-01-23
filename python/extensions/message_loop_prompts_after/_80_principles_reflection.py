"""
Principles Reflection Extension

Injects prompts for outputting self-referential text.
Not actual metacognition - just prompts that cause
the model to generate process-related output.
"""

from python.helpers.extension import Extension
from agent import LoopData
from python.helpers import settings


REFLECTION_INTERVAL = 5
MIN_ITERATIONS = 3


class PrinciplesReflection(Extension):
    """
    Periodically injects prompts that cause output about
    the current process. Useful for user visibility.
    """

    async def execute(self, loop_data: LoopData = LoopData(), **kwargs):

        if loop_data.iteration < MIN_ITERATIONS:
            return

        if loop_data.iteration % REFLECTION_INTERVAL != 0:
            return

        set = settings.get_settings()
        if not set.get("principles_reflection_enabled", True):
            return

        reflection_prompt = self._build_reflection_prompt()

        extras = loop_data.extras_persistent
        extras["principles_reflection"] = reflection_prompt

    def _build_reflection_prompt(self) -> str:
        return """
## Process Check

Output brief status on:
- what was the request?
- what has been done?
- what remains?
- any destructive operations pending? (list consequences)

This is prompt-triggered output generation, not actual reflection.
""".strip()
