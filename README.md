# MoustASK - Moustache Templates for Alexa Skills Kit

This powerful tool enables you to create Alexa skill projects and all their files as [Moustache](https://mustache.github.io/) templates to deploy them with customized settings on the fly. No more need to replicate resources you'd want to share across many Alexa skills.

[Moustache](https://mustache.github.io/) is a logic-less template syntax. It can be used for HTML, config files, source code - anything. [Alexa Skills Kit ASK](https://mustache.github.io/) is a set of tools to build capabilities, or skills, that make Alexa smarter. [MoustASK](https://mustache.github.io/) however is just a tiny shell script that combines both worlds and establishes a very effective way of creating and maintaining the project repositories for many Alexa skills that work on a shared set of resources.

## Alexa Skill Templating powered by [Moustache](https://mustache.github.io/)

* **Context**
    * [What is this for?](#01)
    * [Why do I need it?](#02)
    * [What it does](#03)
* **[Step by Step Guide](#1)**
    * [Prerequisites](#11)
    * **Input**
        * [Create configuration profiles](#12)
        * [Create templates](#13)
        * [Add custom resources (images, audio etc.)](#14)
    * **Output**
        * [Create Alexa skill variants](#15)
        * [Deploy Alexa skill variants](#16)
* **[Best Practices](#2)**
* **[Example](./example/skill-sample-nodejs-fact)**

<a name="01"></a>
###  What is this for?
This tool is made for a scenario where you got several configuration settings for one or many Alexa skills that share most of their resources (i.e. code files, skill metadata, interaction model) with only a few pieces of individual configuration (i.e. invocation name, skill title etc.). A good example are bulk skills as well as stage environments for just one single Alexa skill project.

<a name="02"></a>
###  Why do I need it?
The official ASK CLI tool is not designed for the above described scenarios as it takes static file input (i.e. from _skill.json_ and interaction model schema files) and it does not allow you to ingest settings from external configuration. In order to deploy multiple skills using the same schema, code or metadata you'll need to create individual resource files or modify them manually before you "ask deploy". One good example is the invocation name which is baked into the JSON model files. If you want two skills with different invocation names to share the same interaction model you are required to replicate the model files and put in the respective invocation name. Moreover, those files cannot just exist side by side in one project. The reason is that ASK CLI requires a static file structure (i.e. a US interaction model needs to sit in _/models/en-US.json_) and there is no option to point ASK CLI to another file location. 

<a name="03"></a>
###  What it does
The main idea is to replace individual settings in any files of your skill project with placeholders. This could be in your skill code, in the _skill.json_ file, _.ask/config_ file or interaction model files. You can then go and create different configuration profiles to resolve these placeholders in your source files right before you´d want to deploy a skill. Using [Moustache](https://mustache.github.io/) as a template system makes it very flexible to work with placeholders in source files as it goes way beyond just ingesting single values. It could even contain conditional and formatting logic. [Learn more about Moustache](http://mustache.github.io/mustache.5.html)

<a name="1"></a>
##  How it works

<a name="11"></a>
#### 0) Prerequisites

- The tool is using [Moustache](https://www.npmjs.com/package/mustache) with [Moustache CLI](https://www.npmjs.com/package/mustache-cli). _npm install_ them and you´re good to go.
- Store the _moustask.sh_ shell script in the root folder of your skill project. 

<a name="12"></a>
#### 1) Create configuration profiles

Create a new folder called _templates_ in your skill project root. In it, you should create one to many JSON profiles that store all invididual configuration settings for the skill variants and that should not be stored in your generalized skill project files (aka Moustache templates). There is no fixed format. You'll define the format and refer to it in your source files.

```json
{
    "skillid": "amzn1.ask.skill.b440f3d5-2a08-47ab-b21d-49xxxxxxxxx",
    "functionName": "space-facts",
    "title": { "en": "Space Facts", "de": "Weltraumfakten" },
    "invocation": { "en": "space facts", "de": "weltraumfakten" }
}
```
<a name="13"></a>
#### 2) Turn your skill resource files into Moustache templates

Assume you have an interaction model you´d want to share across many Alexa skills. Instead of entering the invocation name you are putting in a placeholder.

```json
{
  "interactionModel": {
    "languageModel": {
      "invocationName": "{{invocation.en}}",
      "intents": [
        // ...
      ]
    }
  }
}
```

The invocation name is also contained in your Alexa skill metadata. You'll use the same placeholder and another one for the skill title to set up your _skill.json_ file.

```json
{
    "manifest": {
      "publishingInformation": {
        "locales": {
          "en-US": {
            "examplePhrases": [
              "Alexa open {{invocation.en}}",
              "Alexa ask {{invocation.en}} for a fact"
            ],
            "name": "{{title.en}}",
            "description": "This is the fancy {{title.en}} skill. Get started with 'Alexa open {{invocation.en}}'"
          }
        }
      },
      // ...
    }
  }
```

Output speech may also contain individual information like the skill title. Put some more placeholders in your Alexa skill code.

```javascript
const LaunchHandler = {
  // ...
  handle(handlerInput) {
    return handlerInput.responseBuilder.speak('Welcome to the {{title.en}} skill.').getResponse();
  }
};
```

Last but not least you may want to host all skills that share these resources in separate AWS Lambda functions. Put in another placeholder in the _ask config_ file.

```json
{
  "deploy_settings": {
    "default": {
      "skill_id": "{{skillid}}",
      "merge": {
        "manifest": {
          "apis": {
            "custom": {
              "endpoint": {
                "uri": "ask-skill-lambda-{{functionName}}"
              }
            }
          }
        }
      }
    }
  }
}
```

<a name="14"></a>
#### 3) Add individual resources for a configuration profiles

Sometimes skill variants ship with their own file resources as well (i.e. images and audio files). Create a folder in the _templates_ folder which got the same name as the json configuration profile for a skill variant and store any files you need in it.

Your project should now look like the following.

```
/my_skill_project/
│ 
└───/.ask/
│   └───/config
│   
└───/lambda/ ...
│ 
└───/models/
│   └───/en.US.json
│ 
└───/templates/
│   └───/profile1/
│   │   └───/audio.wav
│   │
│   └───/profile1.json
│   └───/profile2.json
│
└───/moustask.sh
└───/skill.json
```

The _templates_ folder contains at least JSON files with the configuration profiles and optionally custom resources like sound files per profile. All your skill resources like _models_, _lambda_ code, _skill.json_ and _config_ files contain placeholders later being fulfilled by the configuration profiles. Last but not least, there´s the _moustask.sh_ shell script which does all the magic.

<a name="15"></a>
#### 4) Generate skill variants

Now execute the shell script. 

```bash
bash ./moustask.sh
```

It picks up all configuration profiles in the _templates_ folder and does the following for each:

1) It clones the entire Alexa skill project with all its files and puts them into a new __dist_ folder in your project.
2) It then looks for [Moustache](https://www.npmjs.com/package/mustache) placeholders in those files and resolves them given your inputs from the configuration profiles.
3) Finally it looks for custom resources in the _templates_ folder and copies them into the __dist_ folder as well.

<a name="16"></a>
#### 5) Deploy Alexa skill variants

Let´s first have a look at the resulting project files below. There´s a new __dist_ folder which contains the replicated skill project - one per configuration profile. The settings from the configuration profiles were injected in the derived skill files. Pay attention to the _audio.wav_ file which is a custom skill resource for _profile1_ and is now part of the skill variant.

```
/my_skill_project/
│   
└───/_dist/
│   └───/profile1/
│   │   └───/.ask/
│   │   │   └───/config
│   │   └───/lambda/
│   │   └───/models/
│   │   └───/audio.wav       
│   │   └───/skill.json    
│   │   
│   └───/profile2/ ...
│     
└───/.ask/ ...
└───/lambda/ ...
└───/models/ ...
└───/templates/ ...
└───/moustask.sh
└───/skill.json
```

Deploying the skill is very simple. Navigate to the skill variant folder (i.e. /_dist/profile1) and deploy with ASK CLI ("ask deploy"). You could as well give shell commands to the _moustask.sh_ directly. It will execute for you.

```bash
bash ./moustask.sh "ask deploy"
```

<a name="2"></a>
## Best Practices

There are a few things you should consider:

1) Never change or modify anything in the __dist_ folder as all changes will be overridden the next time you execute _moustask.sh_. This folder and all its contents should also make it into your _.gitignore_ list. If you want to change something you should do it in the original skill resources (including file operations like rename or delete) and rerun _moustask.sh_. This way you also make sure all your skill variants stay consistent.

2) If you´re deploying a skill variant for the first time a new skill is created in the Alexa database unless you ingest a skillid into the global _.ask/config_ file. The resulting skill id is populated to the _dist/profile/.ask/config_ file. Copy this skill id and put it into your configuration profile (i.e. _profile1.json_) and add a placeholder for the skillid property in the global _.ask/config_ file. 
If you are not doing this your skill variants will be deployed as new skills every time. 

3) Check out all options for Moustache templates and learn how you can also iterate through array sets (e.g. for keywords in your skill metadata) and use conditional formatting in your templates. [Learn more about Moustache](http://mustache.github.io/mustache.5.html)

4) Consider to also use custom resources for skill variants for overwriting template files with a custom version of a file. For instance, one skill variant needs a very different version for _skill.json_. Create a custom _skill.json_ file for that variant and put it into _templates/profile_ folder. It will replace the global _skill.json_ file.  

5) You can give as many as you want shell commands to _moustask.sh_. They will be applied sequentially to the skill variant projects in the __dist_ folder right after creation. For instance, you could use this option to run some tests after deployment.

```bash
bash ./moustask.sh "ask deploy -p custom -t skill" "ls -al" "bst intend MyIntent"
```