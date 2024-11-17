<template>
  <div class="dynamic-dropdown">
    <h2>Select a Vehicle</h2>
    <div class="dropdown-wrapper">
      <label for="year">Year:</label>
      <select
        id="year"
        v-model="selectedYear"
        @change="fetchMakes"
        :disabled="loadingYears"
      >
        <option value="" disabled>Select Year</option>
        <option v-for="year in years" :key="year" :value="year">
          {{ year }}
        </option>
      </select>
      <p v-if="loadingYears">Loading years...</p>
      <label for="make">Make:</label>
      <select
        id="make"
        v-model="selectedMake"
        @change="fetchModels"
        :disabled="!selectedYear || loadingMakes"
      >
        <option value="" disabled>Select Make</option>
        <option v-for="make in makes" :key="make" :value="make" class="option">
          {{ make }}
        </option>
      </select>
      <p v-if="loadingMakes">Loading makes...</p>
      <label for="model">Model:</label>
      <select
        id="model"
        v-model="selectedModel"
        :disabled="!selectedMake || loadingModels"
      >
        <option value="" disabled>Select Model</option>
        <option v-for="model in models" :key="model" :value="model">
          {{ model }}
        </option>
      </select>
      <p v-if="loadingModels">Loading models...</p>
    </div>
    <div v-if="errorMsg" class="error">
      {{ errorMsg }}
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from "vue";
const years = ref([]);
const makes = ref([]);
const models = ref([]);

const selectedYear = ref("");
const selectedMake = ref("");
const selectedModel = ref("");

const loadingYears = ref(false);
const loadingMakes = ref(false);
const loadingModels = ref(false);
const errorMsg = ref(null);

const fetchYears = async () => {
  loadingYears.value = true;
  errorMsg.value = null;
  try {
    const response = await fetch(
      `https://new.api.nexusautotransport.com/api/vehicles/years`,
      {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      }
    );
    if (!response.ok) throw new Error("Failed to fetch car years");
    const data = await response.json();
    years.value = data.data;
  } catch (error) {
    errorMsg.value = error.message;
  } finally {
    loadingYears.value = false;
  }
};

onMounted(fetchYears);

const fetchMakes = async () => {
  if (!selectedYear.value) return;
  loadingMakes.value = true;
  makes.value = [];
  models.value = [];
  selectedMake.value = "";
  errorMsg.value = null;
  try {
    const response = await fetch(
      `https://new.api.nexusautotransport.com/api/vehicles/makes?${selectedYear.value}1`,
      {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      }
    );
    if (!response.ok) throw new Error("Failed to fetch car makes");
    const data = await response.json();
    makes.value = data.data.map((item) => item.name);
  } catch (error) {
    errorMsg.value = error.message;
  } finally {
    loadingMakes.value = false;
  }
};

const fetchModels = async () => {
  if (!selectedYear.value || !selectedMake.value) return;
  loadingModels.value = true;
  models.value = [];
  errorMsg.value = null;
  try {
    const response = await fetch(
      `https://new.api.nexusautotransport.com/api/vehicles/models?year=${selectedYear.value}&make=${selectedMake.value}`,
      {
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      }
    );
    if (!response.ok) throw new Error("Failed to fetch car models");
    const data = await response.json();
    if (data.data.length == 0) {
      console.log(data.data.length);
      errorMsg.value =
        "There are no models for the specific year and make you selected.";
    }
    models.value = data.data.map((item) => item.model);
  } catch (error) {
    errorMsg.value = error.message;
  } finally {
    loadingModels.value = false;
  }
};
</script>
<style>
.dropdown-wrapper label {
  display: block;
  margin-top: 10px;
}

.dropdown-wrapper select {
  display: block;
  margin-bottom: 10px;
  padding: 5px;
  width: 200px;
}
.dropdown-wrapper select:hover {
  cursor: pointer;
}
.error {
  margin-top: 10px;
  color: red;
  font-weight: bold;
}
</style>
