<script setup>
  import { ref, onMounted } from 'vue'
    import "leaflet/dist/leaflet.css"
    import * as L from 'leaflet'

    const initialMap = ref(null)
    const schoolData = ref([])

    const schoolIcon = L.icon({
            iconUrl: '/education.png',
            iconSize:     [32, 32], // size of the icon
        });

    const loadSchoolData = async() => {
        try {
            const response = await fetch('/src/data/sekolah.json');
            schoolData.value = await response.json();

            // Iterate through school data and add markers to the map
            schoolData.value.forEach(school => {
                const { lintang, bujur, npsn, nama_sekolah, alamat } = school;
                const marker = L.marker([lintang, bujur], {icon: schoolIcon}).addTo(initialMap.value);
                marker.bindPopup(`<b>${nama_sekolah}</b><br/>NPSN: ${npsn}<br/>Alamat: ${alamat}`).openPopup();
            })
        } catch (error) {
            console.error('Error loading school data:', error);
        }
    }

    onMounted(async ()=> {
        initialMap.value = L.map('map').setView([-2.6787, 118.8923], 14)
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19, 
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(initialMap.value)
        await loadSchoolData()
    });
</script>
<template>
    <h3>Maps Sekolah tingkat SMA sederajat Sulawesi Barat</h3>
    <div id="map" style="height:90vh;"></div>
</template>
<style scoped>
</style>