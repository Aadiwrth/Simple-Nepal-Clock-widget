#!/usr/bin/env python3
"""
Setup script for Nepal Clock Widget
Enables pip installation and distribution
"""

from setuptools import setup, find_packages
import os
import sys

# Read version from the main module
def get_version():
    try:
        with open('nepal_clock_widget.py', 'r') as f:
            for line in f:
                if line.startswith('__version__'):
                    return line.split('"')[1]
        return '1.0.0'
    except:
        return '1.0.0'

# Read long description from README
def get_long_description():
    if os.path.exists('README.md'):
        with open('README.md', 'r', encoding='utf-8') as f:
            return f.read()
    return "A professional Nepal timezone clock widget with draggable interface."

# Read requirements
def get_requirements():
    requirements = ['pytz>=2023.3']
    if os.path.exists('requirements.txt'):
        with open('requirements.txt', 'r') as f:
            requirements = [line.strip() for line in f if line.strip() and not line.startswith('#')]
    return requirements

setup(
    name='nepal-clock-widget',
    version=get_version(),
    author='Aadiwrth',
    author_email='official@aadiwrth.dpdns.org',
    description='A professional Nepal timezone clock widget',
    long_description=get_long_description(),
    long_description_content_type='text/markdown',
    url='https://github.com/Aadiwrth/Simple-Clock-widget',
    py_modules=['nepal_clock_widget'],
    install_requires=get_requirements(),
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: End Users/Desktop',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Topic :: Office/Business :: Scheduling',
        'Topic :: Utilities',
    ],
    python_requires='>=3.7',
    entry_points={
        'console_scripts': [
            'nepal-clock=nepal_clock_widget:main',
        ],
    },
    keywords='nepal clock timezone widget desktop utility',
    project_urls={
        'Bug Reports': 'https://github.com/Aadiwrth/Simple-Clock-widget/issues',
        'Source': 'https://github.com/Aadiwrth/Simple-Clock-widget',
    },
)