- [Improvement] Running ``tutor dev launch --mount=edx-platform`` now performs all necessary setup for a local edx-platform development. This includes running setup.py, installing node modules, and building assets; previously, those steps had to be run explicitly after bind-mounting a local copy of edx-platform (by @kdmccormick).