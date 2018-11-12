## Example skill project using MoustASK

I picked up the [Alexa space fact skill example from Github](https://github.com/alexa/skill-sample-nodejs-fact) and turned it into a generic fact skill project. 
It is very simple to do the same for your own skills by doing the following:

1) **Eliminate all specifics** that are dedicated to the theme or nature of the skill. In this example I replaced all elements that are dedicated to space with Moustache placeholder tags, such as:

- in _skill.json_: skill title, invocation name in example phrases and skill descriptions, keywords
- in _models/de-DE.json_ and _models/en-US.json_ interaction schema files: invocation name and a few sample utterances that contain the name of the fact theme
- in _lambda/custom/index.js_ code file: output speech elements and most importantly the list of facts Alexa reads out to skill users

2) **Create configuration template** for the skill variants and put it into the _templates_ folder. Based on what I left as placeholders in step one in the source files, I set the actual values for the space fact skill in _templates/space_facts.json_. 

3) **Add more configuration templates** In order to build a new fact skill I just need to create another configuration template. I chose to build a fact skill dedicated to planet mars and set up the _templates/mars_facts.json_ template file.

4) **Add custom skill resources** Optionally, you can store files in the _templates_ folder that should go into a skill variant project. In this example I added the skill icons for each of the two fact skills to a folder equally named as the configuration files so they will be considered by _moustask.sh_ and pulled into the skill variant project in the __dist_ folder.

5) **Generate skill variants from those templates** I simply ran _moustask.sh_ and got the output you can review in the __dist_ folder. I am now ready and set to instantly deploy two individual fact skills. Moreover, it just takes a couple of minutes to create yet another configuration template in the _templates_ folder in order to come up with a bunch of other fact skills.

So much convenience ... :-)