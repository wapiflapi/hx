#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

if sys.version_info < (3, 3, 0):
    from datetime import datetime
    sys.stdout.write("It's %d. This requires Python > 3.3.\n"
                     % datetime.now().year)
    sys.exit(1)

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

readme = open('README.md').read()
requirements = open('requirements.txt').read()

setup(
    name='hx',
    description='A colored hexdump.',
    long_description=readme,
    version='0.2.0',
    author='Wannes `wapiflapi` Rombouts',
    author_email='wapiflapi@yahoo.fr',
    url='https://github.com/wapiflapi/hx',
    license="MIT",
    zip_safe=False,
    keywords='hx',
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
    ],

    scripts=['bin/hx'],
    packages=['hx'],
    package_dir={'hx': 'hx'},

    install_requires=requirements,
)
