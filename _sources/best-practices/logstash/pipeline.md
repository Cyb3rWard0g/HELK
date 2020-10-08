# Pipeline

## Bypass Catch All

since we implemented catch all, but didn't want to impact exisiting implementations/configs and wrap everything into one,
people adding their own output need to add a field of [@metadata][helk_parsed] with value of "yes" anywhere in their config for that specific log type/thing.