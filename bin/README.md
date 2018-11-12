## MoustASK shell script

Copy the _moustask.sh_ shell script to your skill project like you can see it in the example. Once you set up your projects as described in the README simply run it from your CLI and watch out for the new __dist_ folder containing your skill variant projects.

```bash
bash ./moustask.sh
```

### **BEFORE**

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

### **AFTER**

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

Once you got there deploying the skills is very simple. Navigate to the skill variant folder (i.e. /_dist/profile1) and deploy with ASK CLI ("ask deploy"). You could as well give shell commands to the _moustask.sh_ directly. It will execute for you.

```bash
bash ./moustask.sh "ask deploy"
```

You can give as many as you want shell commands to _moustask.sh_. They will be applied sequentially to the skill variant projects in the __dist_ folder right after creation. For instance, you could use this option to run some tests after deployment.

```bash
bash ./moustask.sh "ask deploy -p custom -t skill" "ls -al" "bst intend MyIntent"
```