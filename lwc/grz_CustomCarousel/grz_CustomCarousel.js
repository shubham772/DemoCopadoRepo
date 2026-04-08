import { LightningElement, track, api } from 'lwc';
import getBannerData from '@salesforce/apex/Grz_SalesOrderFeaturedProductsController.getBannerData';
export default class Grz_CustomCarousel extends LightningElement {

    @track carouselItems = [];
    @track currentIndex = 0;
    @track autoSlideInterval;
    @track isShowTextBox = false;
    connectedCallback() {
        this.retrieveBannerDetails();
        this.carouselItems = this.updatedItems;
        this.startAutoSlide();
    }
    disconnectedCallback() {
        this.stopAutoSlide();
    }
    handleMouseEnter() {
        this.stopAutoSlide();
    }

    handleMouseLeave() {
        this.startAutoSlide();
    }

    retrieveBannerDetails() {
        getBannerData().then(data => {
        this.carouselItems = data.map(carousel => {
            const rawDesc = carousel.Description || '';
            const noTags = rawDesc.replace(/<[^>]+>/g, '');
            return {
                ...carousel,
                Description: noTags,
                isActive: false,
                isShowTextBox : (carousel.Title && carousel.Description) || (carousel.Title ||  carousel.Description) ? true : false
            };
        });
        if (this.carouselItems.length > 0) {
            this.carouselItems[0].isActive = true;
        }
        }).catch(error => {
            console.log('Error in fetching Banner Data---->', error);
        })
    }
    renderedCallback() {
    if (this.carouselItems.length > 0) {
        const currentItem = this.carouselItems[this.currentIndex];
        const container = this.template.querySelector(`div[data-id="${currentItem.Id}"]`);
        if (container && currentItem.Description) {
                container.innerHTML = currentItem.Description
            } 
        }
    }
    
    
    get currentBackground() {
        return `background-image: url('${this.carouselItems[this.currentIndex].ImageUrl}');`
    }

    get updatedItems() {
        return this.carouselItems.map((item, index) => {
            return {
                ...item,
                isActive: index === this.currentIndex,
                dotClass: index === this.currentIndex ? 'dot active' : 'dot'
            };
        });
    }
    nextSlide() {
        this.currentIndex = (this.currentIndex + 1) % this.carouselItems.length;
        this.carouselItems = this.updatedItems;
    }

    prevSlide() {
        this.currentIndex = (this.currentIndex - 1 + this.carouselItems.length) % this.carouselItems.length;
        this.carouselItems = this.updatedItems;
    }

    goToSlide(event) {
        this.currentIndex = parseInt(event.target.dataset.index, 10);
        this.carouselItems = this.updatedItems;
        this.stopAutoSlide();
        this.startAutoSlide(); // **Restart auto-slide on manual selection**
    }

    startAutoSlide() {
        this.autoSlideInterval = setInterval(() => {
            this.nextSlide();
        }, 10000);
    }

    stopAutoSlide() {
        clearInterval(this.autoSlideInterval);
    }

}