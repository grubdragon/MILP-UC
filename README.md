# MILP-UC
The unit commitment problem (UC) in electrical power production is a large family of mathematical optimization problems where the production of a set of electrical generators is coordinated in order to achieve some common target, usually either match the energy demand at minimum cost or maximize revenues from energy production. This is necessary because it is difficult to store electrical energy on a scale comparable with normal consumption; hence, each (substantial) variation in the consumption must be matched by a corresponding variation of the production.
This optimization project is on the unit commitment problem and its MILP solution, with linearized constraints/objective.


## Usage

Run the project using the MATLAB GUI file `UC_gui.m`. Data should be fed in the form of CSVs with CSV represented with the following fields:

Pmax | Pmin | a | b | c | min up | min down | hot start cost | cold start cost | coldstart hrs | init stat
 --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- 
Unit 1 | | | | | | | | | | 
Unit 2 | | | | | | | | | | 
... | | | | | | | | | | 

Demand should be provided in the format below

Demand | 254 | 23 | 425 | 323 | ...

Note that the above would represent demand at specific time period.
Time | 1 | 2 | 3 | 4 | ... 


Start with loading Demand and Unit data, using the two buttons. Then press the Display Units button and check the output in MATLAB. Implies that the program isn't stuck on a particular step.

Then tap the Solve button and the Display Units button. Might take a while for "oui" to show up, since solving the problem takes time.

Once it is solved, clicking "Show Power Graph" will output different graphs for the unit powers, solved with `inlinprog`. Clicking Show Unit Commitment will output a 0, 1 unit commitment image.



## Some Troubleshooting
```
ERROR - (intlinprog): problem must contain at least "f", "intcon", A" and "b".
Output argument "x" (and maybe others) not assigned during call to "intlinprog".
```
For the error type above, ensure that you don't have an external 'intlinprog' library installed. Popular examples are ***mosek*** and ***yalmip***.


