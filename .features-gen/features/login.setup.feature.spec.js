// Generated from: features/login.setup.feature
import { test } from "playwright-bdd";

test.describe('Persistencia de Sesión:', () => {

  test('1. Login exitoso y guardar estado', async ({ Given, When, Then, And, page }) => { 
    await Given('abro la pagina de login', null, { page }); 
    await When('ingreso credenciales validas "student" y "Password123"', null, { page }); 
    await Then('veo el dashboard de exito', null, { page }); 
    await And('guardo la sesion en el archivo "auth.json"', null, { page }); 
  });

});

// == technical section ==

test.use({
  $test: [({}, use) => use(test), { scope: 'test', box: true }],
  $uri: [({}, use) => use('features/login.setup.feature'), { scope: 'test', box: true }],
  $bddFileData: [({}, use) => use(bddFileData), { scope: "test", box: true }],
});

const bddFileData = [ // bdd-data-start
  {"pwTestLine":6,"pickleLine":2,"tags":[],"steps":[{"pwStepLine":7,"gherkinStepLine":3,"keywordType":"Context","textWithKeyword":"Given abro la pagina de login","stepMatchArguments":[]},{"pwStepLine":8,"gherkinStepLine":4,"keywordType":"Action","textWithKeyword":"When ingreso credenciales validas \"student\" y \"Password123\"","stepMatchArguments":[{"group":{"start":29,"value":"\"student\"","children":[{"start":30,"value":"student","children":[{"children":[]}]},{"children":[{"children":[]}]}]},"parameterTypeName":"string"},{"group":{"start":41,"value":"\"Password123\"","children":[{"start":42,"value":"Password123","children":[{"children":[]}]},{"children":[{"children":[]}]}]},"parameterTypeName":"string"}]},{"pwStepLine":9,"gherkinStepLine":5,"keywordType":"Outcome","textWithKeyword":"Then veo el dashboard de exito","stepMatchArguments":[]},{"pwStepLine":10,"gherkinStepLine":6,"keywordType":"Outcome","textWithKeyword":"And guardo la sesion en el archivo \"auth.json\"","stepMatchArguments":[{"group":{"start":31,"value":"\"auth.json\"","children":[{"start":32,"value":"auth.json","children":[{"children":[]}]},{"children":[{"children":[]}]}]},"parameterTypeName":"string"}]}]},
]; // bdd-data-end