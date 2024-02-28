<script setup>
  import SchoolMap from './components/SchoolMap.vue'
  import SearchSchool from './components/SearchSchool.vue'
  import NewSearch from './components/NewSearch.vue';
  import BingMaps from './components/BingMaps.vue';
</script>

<template>
  <BingMaps />
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
