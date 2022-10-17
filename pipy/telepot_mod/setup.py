import setuptools

#with open("README.md", "r") as fh:
#    long_description = fh.read()

setuptools.setup(
    name="telepot_mod", # Replace with your own username
    version="0.0.1",
    author="telepot_mod",
    author_email="telepot_mod@gmail.com",
    description="telepot_mod",
    long_description="",
    long_description_content_type="text/markdown",
    url="",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.9',

    #package_dir={"flaskfarm": "src"},
    #packages=setuptools.find_packages(where="src"),
    #packages=['flaskfarm'],
    #py_modules=['flaskfarm'],
    #package_data={'flaskfarm' :['flaskfarm/files/*','flaskfarm/lib/*']}
)
