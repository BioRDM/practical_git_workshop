# practical_git_workshop

A short workshop on the basics of using git and GitHub, with an emphasis on practical advice. Initially created for the Ambient-BD project.

## Contents

Presentation: contains the slides used during the workshop. Double-click on the `.html` file to open the slides in a web browser. The source code for the files (in quarto markdown format) can be found in the `.qmd` file.

Helpsheets contains the git glossary and markdown help sheet, in pdf and svg format.

Exercise materials contains an example R script and some fake data, that can be used to practice using git.

## Authors

Daniel Thédié (BioRDM team) - [daniel.thedie@ed.ac.uk](mailto:daniel.thedie@ed.ac.uk)

## Delivery

Please refer to the notes below if you are planning to use the materials to deliver the workshop yourself.

These notes are based on the workshop delivered by Daniel Thedie to the Chronopsychiatry group (University of Edinburgh) on 18/02/2026.

### General info

The workshop was a 2-hour session, and 9 people attended. Before the workshop, participants were asked to register a GitHub account, and to bring a laptop with RStudio installed. It would be good to also ask them to install git (for windows users), as one participant did not have it pre-installed, and had to do it during the workshop.

RStudio was chosen because all participants used (or were planning to use) R as a programming language, but the training could be adapted to use another IDE, e.g. VSCode. In any case, I would strongly recommend using a GUI interface to git rather than the command line, as it allows participants to focus more on the philosophy of git than on the technicality of using a terminal and memorising git commands.

### Timeline

The workshop starts with a "check-in", where we ask the participants "What makes you want to use GitHub", and "What makes you *not* want to use GitHub". This should take ~10 min, and use the following structure (for each question). It is useful for everyone to question their own motivations and fears, and to (often) see that other people might have similar thoughts. It can also be useful for instructors to see where potential difficulties might arise.

1. Participants think about their answers individually, and write them down on their own notes (~1 min)
2. Participants discuss their answers in small groups of 2-3 people (~ 2-3 min)
3. Participants share their reflections to the whole group. This is entirely optional, do not ask specific people to talk

After the check-in, the workshop is divided in 4 unequal parts:

1. Basics of git and GitHub
2. git branches
3. Good coding practices
4. GitHub functionalities

Part 1 is the most important, as it explains the basics of working with git, and lets participants create a git repository (which can take some time, as there are several steps). Aim to finish this part roughly halfway through the workshop (1h mark). Once everyone has created their repository, it is a good time to have a 5-10 min break.

Part 2 is a lot faster, but it is good to take time to explain the branch concept, as most people are not familiar with it.

Part 3 focuses more on code (could be adapted to another language, e.g. Python, if relevant). Ideally, it would be good to let people practice making their own functions, but that would require at least 15-20 min. As I didn't have time, I skipped the exercise and gave participants 5 min to look at their code (or the example provided) and think about what functions they could create.

Part 4 is again fairly quick, but do take the time to explain in details how to do merges, conflict resolution, and the benefits of using issues for collaborative work.

### Instructors

The practical parts of the workshop (creating a repository, creating a branch, writing functions, and merging branches), require some input from instructors to address small issues. This was especially true in the first part (repository creation). It was ok to be on my own with 9 participants, but I think any more could have been a stretch. I would recommend a minimum of 1 instructor for ~10 participants, otherwise there's a risk of exercises taking too much time, or some people being left behind.

### Feedback

Feedback from participants (given on post-it notes at the end of the workshop) was positive. Some of the things that several participants mentioned they enjoyed:

- The step-by-step instructions for exercises, with screenshots
- Focusing on "why we do things" (why use git, why use branches,...) rather than listing git commands

Things participants said they were glad to have learned about, and/or want to look into more in the future:

- Using git branches
- Using functions in code

No particular point for improvement was raised, but several participants expressed that they would have liked to spend more time learning about functions. I think this could be a really useful extension if the workshop can be delivered in 2.5 or 3 hours.
