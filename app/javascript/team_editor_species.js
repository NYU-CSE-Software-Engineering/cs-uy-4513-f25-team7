// app/javascript/team_editor_species.js

const SPECIES_LOOKUP_URL = "/api/lookup/species";

// cache: name (lowercase) -> species object { name, sprite_url, ... }
const speciesCache = {};

function debounce(fn, delay) {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

async function fetchSpecies(query) {
  const url = `${SPECIES_LOOKUP_URL}?q=${encodeURIComponent(query)}`;
  const response = await fetch(url, {
    headers: { "Accept": "application/json" }
  });
  if (!response.ok) return [];
  return await response.json();
}

function updateDatalist(datalist, speciesList) {
  if (!datalist) return;

  datalist.innerHTML = "";
  speciesList.forEach((s) => {
    if (!s || !s.name) return;

    const opt = document.createElement("option");
    opt.value = s.name;
    datalist.appendChild(opt);

    if (s.name) {
      speciesCache[s.name.toLowerCase()] = s;
    }
  });
}

function updateSpriteForInput(input) {
  if (!input) return;

  const field = input.closest('[data-role="species-field"]');
  if (!field) return;

  const spriteContainer = field.querySelector('[data-role="species-sprite"]');
  if (!spriteContainer) return;

  const key = input.value.trim().toLowerCase();
  const species = speciesCache[key];

  spriteContainer.innerHTML = "";

  if (!species || !species.sprite_url) {
    return; // nothing to show
  }

  const img = document.createElement("img");
  img.src = species.sprite_url;
  img.alt = `${species.name} sprite`;
  img.style.imageRendering = "pixelated";
  img.style.width = "96px";
  img.style.height = "96px";

  spriteContainer.appendChild(img);
}

function wireSpeciesField(input) {
  const listId = input.getAttribute("list");
  const datalist = listId ? document.getElementById(listId) : null;

  const performLookup = debounce(async () => {
    const query = input.value.trim();
    if (query.length < 2) {
      if (datalist) datalist.innerHTML = "";
      return;
    }

    try {
      const results = await fetchSpecies(query);
      updateDatalist(datalist, results);
    } catch (e) {
      // Fail silently; this is just a convenience feature
      console.error("Species lookup failed", e);
    }
  }, 200);

  input.addEventListener("input", () => {
    performLookup();
  });

  input.addEventListener("change", () => {
    updateSpriteForInput(input);
  });

  // When leaving the field, update sprite after user chooses from datalist
  input.addEventListener("blur", () => {
    setTimeout(() => updateSpriteForInput(input), 100);
  });
}

function initTeamEditorSpecies() {
  const inputs = document.querySelectorAll('[data-role="species-input"]');
  if (!inputs.length) return;

  inputs.forEach((input) => wireSpeciesField(input));
}

// Support both plain DOM load and Turbo (Rails 7)
document.addEventListener("DOMContentLoaded", initTeamEditorSpecies);
document.addEventListener("turbo:load", initTeamEditorSpecies);
