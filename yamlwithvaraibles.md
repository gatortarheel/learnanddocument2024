# Use Output from a Console Application in a Build Pipeline

## Context
Use the output from a console application to verify that the proposed code changes do not affect performance.

- [ ] Run the console application
- [ ] Put the output of the console application into a variable for making pipeline decisions
- [ ] Use the output variable to make decisions

---

## Requirements

The compiled artifact needs to be ‘published’ self-contained. We will eventually do this in a build pipeline.
This can be then added to a repo and referenced and cross referenced like we do other items in the repo [build scripts].
---

## Resources
[Set variables in scripts](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-variables-scripts?view=azure-devops&tabs=powershell#set-an-output-variable-for-use-in-future-stages)

---

## The C# POC console app
```CSharp
public class Program
{
    static void Main(string[] args)
    {
        bool isEvenMinute = IsEvenMinute();
        Console.WriteLine(isEvenMinute);
    }

    static bool IsEvenMinute()
    {
        DateTime currentTime = DateTime.Now;
        int minute = currentTime.Minute;
        bool isEven = minute % 2 == 0;
        return isEven;
    }
}
```

## Pipeline Overview

::: mermaid
graph TD
    A[Start] --> B{Output = TRUE?}
    B -->|Yes| C[Deploy Web Application]
    B -->|No| D[Send message to Build Pipeline]
    D --> E[Fix Issues]
    E --> B
:::




## Console App Stage
### Get the output and set the output to a `variable`
- Output variables are only available in the next downstream stage. 
- If multiple stages consume the same output variable, use the `dependsOn` condition.
```YAML
##Output variables are only available in the next downstream stage. 
##If multiple stages consume the same output variable, use the dependsOn condition.
stages:
- stage: CAS
  displayName: 'Console Verification POC'
  jobs:
  - job: RunConsoleApplication
    displayName: 'Run Console Application'
    pool:
      vmImage: 'windows-latest'
    steps:
    - task: PowerShell@2
      name: SetAppVar
      displayName: 'SetConsoleApplication'
      inputs:
        targetType: 'inline'
        script: |
          # Run the console application
          $output = .\testconsoleappfordevops\testconsoleappfordevops.exe
          Write-Output "Output of the console application: $output"
          Write-Host "##vso[task.setvariable variable=consoleVal;isOutput=true]$output"
                       
```

### Console App Stage Walkthrough
---
- `stage: CAS`: Defines a stage named `CAS`. 
- `jobs`: Contains a list of jobs to be executed within the stage.
- `- job: RunConsoleApplication`: Defines a job named "RunConsoleApplication" within the `CAS` stage.
  - `displayName: 'Run Console Application'`: Sets the display name for the job to "Run Console Application."
    - `steps`: Contains a list of steps to be executed within the job.
    - `- task: PowerShell@2`: Defines a PowerShell task to be executed as part of the job.
      - `name: SetAppVar`: Assigns a name to the PowerShell task.
      - `displayName: 'SetConsoleApplication'`: Sets the display name for the task to `SetConsoleApplication.`
      - `inputs`: Contains input parameters for the PowerShell task.
        - `targetType: 'inline'`: Specifies that the PowerShell script is provided inline within the YAML file.
        - `script`: Contains the PowerShell script to be executed.
          - The script runs a console application named "testconsoleappfordevops\testconsoleappfordevops.exe."
          - It captures the output of the console application in a variable named "$output."
          - It uses the `Write-Host` command to print the output of the console application to the console.
          - It uses the `##vso[task.setvariable]` command to set a pipeline variable named "consoleVal" with the value of the output of the console application. The `isOutput=true` flag indicates that this variable will be available for use in subsequent stages of the pipeline.
---

### Read the variable and success or fail the stage based on the output.
```YAML
- stage: CBS
  dependsOn: CAS
  jobs:
  - job: C1
    variables:
      testConsoleAppVar: $[stageDependencies.CAS.RunConsoleApplication.outputs['SetAppVar.consoleVal']]
    steps:
    - task: PowerShell@2
      inputs:
        targetType: 'inline'
        script: |
           Write-Host "Here is your testConsoleAppVar: $(testConsoleAppVar)"
    - task: PowerShell@2
      inputs:
       targetType: 'inline'
       script: |
        if ("$(testConsoleAppVar)" -ne "TRUE") {
            Write-Host "Deployment should not continue. Please check console app logs."
            exit -1
           }
           else
           {
             Write-Host "Deployment may continue."
           }

 ```
This YAML configuration defines a stage named `CBS`, which depends on the successful completion of the `CAS` stage. Within the `CBS` stage, there's a single job named `C1` responsible for executing tasks related to the console application.

- `stage: CBS`: Defines a stage named `CBS` that `depends on` the completion of the `CAS` stage.
  - `jobs`: Contains a list of jobs to be executed within the stage.
    - `- job: C1`: Defines a job named `C1` within the `CBS` stage.
      - `variables`: Defines variables specific to this job.
        - `testConsoleAppVar`: Assigns the value of the output variable `SetAppVar.consoleVal` from the `RunConsoleApplication` job in the `CAS` stage to the variable `testConsoleAppVar` in this job.
      - `steps`: Contains a list of steps to be executed within the job.
              - The script uses `Write-Host` to output the value of the `testConsoleAppVar` variable.
              - The script checks if the value of `testConsoleAppVar` is not equal to `TRUE.` If it is not, it outputs a message indicating that the deployment should not continue and exits with a negative status code.
---

### Conditionally deploy the application based on the previous stage success or fail.
```YAML
- stage: ConditionalStage
  displayName: Conditional Stage
  dependsOn: CBS
  condition: succeeded()
  jobs:
  - job: ConditionalJob
    displayName: Conditional Job
    steps:
    - script: echo "This job will execute because testConsoleAppVar is true"
```


