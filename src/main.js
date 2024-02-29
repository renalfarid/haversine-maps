import { createApp } from 'vue';
import './style.css';
import App from './App.vue';
import { SnackbarService } from "vue3-snackbar";
import "vue3-snackbar/styles";

const app = createApp(App);
app.use(SnackbarService)

app.mount('#app')
