<script setup>
  import { ref, onMounted } from 'vue';
  
  import "leaflet/dist/leaflet.css";
  import * as L from 'leaflet';
  import { Vue3Lottie } from 'vue3-lottie';
  import loadingJson from '../assets/loading.json';
  import { Vue3Snackbar } from "vue3-snackbar";

  import { useSnackbar } from "vue3-snackbar";
  const snackbar = useSnackbar();
  

  const gmapsKey = import.meta.env.VITE_GOOGLE_MAPS_KEY


  const initialMap = ref(null)

  const isLoading = ref(false)

  const errorMessage = ref('')

  // Define refs for input values
  const studentName = ref('')
  const studentAddress = ref('')
  const studentLatitude = ref(0)
  const studentLongitude = ref(0)
  const schoolData = ref([])
  const isFound = ref(false)

  const npsn = ref('');
  const namaSekolah = ref('');
  const alamatSekolah = ref('');
  const schoolDistance = ref(0);
  const listNearestSchool = ref([]);

  const schoolIcon = L.icon({
            iconUrl: '/education.png',
            iconSize:     [32, 32], // size of the icon
        });
const homeIcon = L.icon({
            iconUrl: '/school-icon.png',
            iconSize:     [32, 32], // size of the icon
        });

  const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371; // Radius of the Earth in kilometers
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c; // Distance in kilometers
    return distance;
  };

  const loadSchoolData = async() => {
        try {
            const response = await fetch('/data/sekolah.json');
            schoolData.value = await response.json();

        } catch (error) {
            console.error('Error loading school data:', error);
        }
  }

  const findNearestSchool = async () => {
    await loadSchoolData();

    const studentLat = studentLatitude.value;
    const studentLon = studentLongitude.value;

    if (studentLat === 0 || studentLon === 0) {
        console.error('Student coordinates not available');
        return;
    }

    const sortedSchools = schoolData.value
        .filter((school) => school.bentuk_pendidikan === "SMA" && school.lintang !== null && school.bujur !== null)
        .map((school) => {
        const distance = calculateDistance(studentLat, studentLon, school.lintang, school.bujur);
        return { ...school, distance };
        })
        .sort((a, b) => a.distance - b.distance)
        .slice(0, 3);

    listNearestSchool.value = sortedSchools.map((school) => ({
        npsn: school.npsn,
        namaSekolah: school.nama_sekolah,
        alamatSekolah: `${school.alamat}, ${school.desa} ${school.kecamatan} ${school.kab_kota}`,
        distance: school.distance.toFixed(2) + ' km',
        lintang: school.lintang,
        bujur: school.bujur
    }));

  };
  
  // Define a method to handle form submission
  const handleSubmit = async() => {

    try {
      isLoading.value = true;
      const response = await fetch(
        `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(studentAddress.value)}&key=${gmapsKey}`
      );

      if (!response.ok) {
        errorMessage.value = 'Failed to fetch coordinates';
        snackbar.add({
          type: 'error',
          text: `${errorMessage.value}`
        });
        isLoading.value = false;
        throw new Error('Failed to fetch coordinates');
      }

      const data = await response.json();

      if (data.results && data.results.length > 0) {
        const location = data.results[0].geometry.location;
        
        studentLatitude.value = location.lat;
        studentLongitude.value = location.lng;

        await findNearestSchool();
        await markingMap();
        


      } else {
        errorMessage.value = 'No results found for the provided address';
        snackbar.add({
          type: 'error',
          text: `${errorMessage.value}`
        });
        isLoading.value = false;
        throw new Error('No results found for the provided address');
      }
      isLoading.value = false;
    } catch (error) {
      errorMessage.value = 'Error fetching coordinates';
        snackbar.add({
          type: 'error',
          text: `${errorMessage.value}`
        });
        isLoading.value = false; 
      console.error('Error fetching coordinates:', error.message);
    }
  };

  const markingMap = async () => {
    // Clear all existing markers
    initialMap.value.eachLayer((layer) => {
        if (layer instanceof L.Marker) {
            initialMap.value.removeLayer(layer);
        }
    });
    
    let marker1 = null;
    let schoolMarker = null;
    let bounds = null;

    
    marker1 = L.marker([studentLatitude.value, studentLongitude.value], {icon: homeIcon}).addTo(initialMap.value)
    marker1.bindPopup(`<b>Student Home</b> <br>
    <b>${studentName.value}</b><br>
    Alamat: ${studentAddress.value} 
    `);
    
    // Add markers for nearest schools
    listNearestSchool.value.forEach((school) => {
        schoolMarker = L.marker([school.lintang, school.bujur], {icon: schoolIcon}).addTo(initialMap.value);
        schoolMarker.bindPopup(`
        <b>${school.namaSekolah}</b><br>
        <b>NPSN: ${school.npsn}</b><br>
        Alamat: ${school.alamatSekolah}<br>
        Jarak: ${school.distance}
        `);
        
    });

    // Fit the map to show all markers
    bounds = L.latLngBounds([
        [studentLatitude.value, studentLongitude.value],
        ...listNearestSchool.value.map((school) => [school.lintang, school.bujur]),
    ]);
    initialMap.value.fitBounds(bounds);
    initialMap.value.invalidateSize();
  }

  onMounted(async ()=> {
        initialMap.value = L.map('map').setView([-2.6787, 118.8923], 14)
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19, 
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(initialMap.value)
    });
</script>

<template>
  <vue3-snackbar bottom right :duration="4000"></vue3-snackbar>
  <div class="mt-10 flex md:flex flex-col md:flex-row items-center rounded-md shadow-md">
      <!-- Form Section -->
      <div class="w-full md:w-full lg:w-full mb-4">
        <div class="max-w-screen-sm p-6 bg-white rounded-md">
          <h3 class="p-3 text-md font-semibold mb-4 bg-blue-500 text-white">Cari Sekolah</h3>
  
          <form @submit.prevent="handleSubmit">
            <!-- Student Name Input -->
            <div class="mb-4">
              <label for="studentName" class="block text-sm font-medium text-gray-600">Student Name:</label>
              <input
                type="text"
                id="studentName"
                v-model="studentName"
                placeholder="Enter student name"
                class="mt-1 p-2 border rounded-md w-full"
              />
            </div>
  
            <!-- Student Address Textarea -->
            <div class="mb-4">
              <label for="studentAddress" class="block text-sm font-medium text-gray-600">Student Address:</label>
              <textarea
                id="studentAddress"
                v-model="studentAddress"
                placeholder="Enter student address"
                class="mt-1 p-2 border rounded-md w-full h-36"
              ></textarea>
            </div>
  
            <!-- Submit Button -->
            <button
              type="submit"
              class="bg-blue-500 text-white p-2 rounded-md hover:bg-blue-600 transition duration-300"
            >
              Cari Sekolah
            </button>
          </form>
        </div>
      </div>
  
      <!-- Result Section -->
      <div class="w-full md:w-full lg:w-full mb-4">
        <div class="p-6 bg-white rounded-md">
          <!-- Loading Animation -->
          <div v-if="isLoading" class="flex items-center justify-center h-screen">
            <vue3-lottie :animation-data="loadingJson" :height="200" :width="200" />
          </div>
  
          <!-- List of Nearest Schools -->
          <h3 class="p-3 text-md font-semibold mb-6 bg-blue-500 text-white">Sekolah Terdekat</h3>
          <div v-if="listNearestSchool.length > 0">
            <div
              v-for="school in listNearestSchool"
              :key="school.npsn"
              class="p-3 mb-4 p-4 border rounded-md"
            >
              <h2 class="p-3 mb-4 text-lg font-semibold bg-blue-400 text-white">{{ school.namaSekolah }}</h2>
              <p class="text-gray-700"><b>NPSN: {{ school.npsn }}</b></p>
              <p>Alamat: {{ school.alamatSekolah }}</p>
              <p>Jarak: {{ school.distance }}</p>
            </div>
          </div>
          <div v-else>
            <p>No schools found.</p>
          </div>
        </div>
      </div>
  
      <!-- Maps Section -->
      <div class="w-full md:w-full mb-4">
        <div class="p-6 bg-white rounded-md">
          <h3 class="p-3 text-md font-semibold mb-4 bg-blue-500 text-white">Maps Sekolah Terdekat</h3>
          <div id="map" style="height:50vh;"></div>
        </div>
      </div>
    </div>
  </template>
  