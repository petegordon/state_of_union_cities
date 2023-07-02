
const puppeteer = require('puppeteer');
const fs = require('fs');

resultArray = []

async function validateLink(obj) {
  const { link, year } = obj;

  console.log(year)
  console.log(typeof year)
  if (parseInt(year) < 1775 || parseInt(year) > 2030) {
    console.log(`Invalid year: ${year}`);
    return;
  }

  try {
    const browser = await puppeteer.launch({headless: 'new'});
    const page = await browser.newPage();
    await page.goto(link);

    // Perform any required actions on the page

    const fieldDocsContent = await page.$('.field-docs-content');
    if (fieldDocsContent) {
      const innerText = await page.evaluate(element => element.innerText, fieldDocsContent);
      const resultObject = { year, fieldDocsContent: innerText }; // Create result object
      resultArray.push(resultObject); // Add result object to array
    } else {
      console.log('Element with class "field-docs-content" not found.');
    }

    await browser.close();
  } catch (error) {
    console.error(`Error visiting link: ${link}`, error);
  }
}

async function processJsonFile(jsonFile) {
  try {
    const jsonData = fs.readFileSync(jsonFile);
    const dataArray = JSON.parse(jsonData);

    for (const obj of dataArray) {
      await validateLink(obj);
    }
    const resultJson = JSON.stringify(resultArray, null, 2);
    fs.writeFileSync('state_of_union_result.json', resultJson);
    console.log('Result saved to state_of_union_result.json');

  } catch (error) {
    console.error('Error reading JSON file:', error);
  }
}

// Replace 'input.json' with the path to your JSON file
processJsonFile('state_of_union_links.json');


