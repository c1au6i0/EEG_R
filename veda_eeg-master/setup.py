from setuptools import setup, find_packages
from pip.req import parse_requirements
import os

package_name = os.path.dirname(os.path.realpath(__file__))
# parse_requirements() returns generator of pip.req.InstallRequirement objects
install_reqs = parse_requirements('./requirements.txt', session=False)

# reqs is a list of requirement
# e.g. ['django==1.5.1', 'mezzanine==1.4.6']
reqs = [str(ir.req) for ir in install_reqs]

setup(
    name='veda_eeg',
    version="0.0.1",
    packages=find_packages(),
    #scripts=['bin/'],

    # Project uses reStructuredText, so ensure that the docutils get
    # installed or upgraded on the target machine
    install_requires=reqs,


    package_data={
        # If any package contains *.txt or *.rst files, include them:
        'PyEphys': ['DataStructures/*.json','DataStructures/oldStuff/*.json' ],
        'spikesortergl':['External/bins/KlustaKwik'],
        # And include any *.msg files found in the 'hello' package, too:
        # 'hello': ['*.msg'],
    },

    # metadata for upload to PyPI
    author="Alessandro Scaglione",
    author_email="alessandro.scaglione@gmail.com",
    description="This package provides custom utilities to interact with google spread",
    license="PSF",
    keywords="hello world example examples",
    url="http://example.com/HelloWorld/",   # project home page, if any

    # could also include long_description, download_url, classifiers, etc.
)
