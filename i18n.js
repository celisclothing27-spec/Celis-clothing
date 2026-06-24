// Translation system for Celis clothing store
var YUN_I18N = {
  currentLang: localStorage.getItem('yun_lang') || 'en',
  translations: {
    en: {
      nav_home: 'Home',
      nav_products: 'Products',
      hero_title: 'FASHION REVIVAL // DIGITAL AGE',
      hero_subtitle: 'Redefining style for the digital generation',
      hero_cta: '\u2192VIEW COLLECTION\u00bb',
      cat_title: 'digital // archives',
      footer_follow: 'Follow Us',
      footer_contact: 'Contact',
      footer_tawssil: 'Tawssil (Zr Express)',
      footer_rights: 'All rights reserved',
      footer_made: 'Made in Algeria',
      view_products: 'VIEW COLLECTION \u2192',
      loading: 'Loading...',
      cart_title: 'CART',
      cart_empty: 'Your cart is empty',
      cart_explore: 'EXPLORE PRODUCTS \u2192',
      cart_subtotal: 'SUBTOTAL',
      cart_shipping: 'SHIPPING',
      cart_total: 'TOTAL',
      cart_checkout: 'PROCEED TO CHECKOUT \u2192',
      cart_continue: '\u2190 CONTINUE SHOPPING',
      filter_all: 'All',
      sort_featured: 'Sort: Featured',
      sort_price_asc: 'Price: Low to High',
      sort_price_desc: 'Price: High to Low',
      sort_newest: 'Newest First',
      search_placeholder: 'Search products...',
      no_products: 'No products found.',
      failed_load: 'Failed to load products. Please refresh.',
      back_products: '\u2190 Back to Products',
      color: 'Color',
      size: 'Size',
      size_chart: 'Size Chart',
      quantity: 'Quantity',
      add_cart: 'ADD TO CART',
      nav_cart: 'Cart',
      checkout_title: 'CHECKOUT',
      personal_info: 'Personal Information',
      first_name: 'First Name',
      last_name: 'Last Name',
      phone_number: 'Phone Number',
      second_phone: 'Second Phone',
      second_phone_optional: '(Optional)',
      delivery_method: 'Delivery Method',
      step_delivery_type: 'Step 1: Choose Delivery Type',
      step_delivery_service: 'Step 2: Choose Delivery Service',
      step_delivery_info: 'Step 3: Delivery Information',
      home_delivery: 'Home Delivery',
      home_delivery_desc: 'Delivered to your door',
      pickup_point: 'Pickup Point',
      pickup_desc: 'Collect from station',
      home_address: 'Detailed Address',
      address_placeholder: 'Street name, building, etc...',
      order_notes: 'Order Notes',
      notes_optional: '(Optional)',
      notes_placeholder: 'Delivery preferences, etc...',
      order_summary: 'ORDER SUMMARY',
      place_order: 'PLACE ORDER',
      terms: 'By placing your order, you agree to our terms & conditions.',
      select_wilaya: 'Select Wilaya',
      select_commune: 'Select Commune',
      select_wilaya_first: 'Select Wilaya first',
      commune: 'Commune',
      stop_desk: 'Stop Desk',
      empty_cart: 'Your cart is empty.',
      explore_products: 'EXPLORE PRODUCTS \u2192',
      product_not_found: 'Product not found.',
      related_products: 'Related Products',
      in_stock: 'In Stock',
      low_stock: 'Low Stock',
      out_of_stock: 'OUT OF STOCK',
      size_chart_title: 'SIZE CHART',
      cm: 'cm',
      about_title: 'About Celis clothing',
      about_p1: 'Celis clothing is a fashion brand born in Algeria.',
      about_p2: 'We blend retro-futuristic aesthetics with street culture.',
    },
    ar: {
      nav_home: '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629',
      nav_products: '\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
      hero_title: '\u0625\u064a\u0647\u0627\u0621 \u0623\u0632\u064a\u0627\u0621 // \u0627\u0644\u0639\u0635\u0631 \u0627\u0644\u0631\u0642\u0645\u064a',
      hero_subtitle: '\u0625\u0639\u0627\u062f\u0629 \u062a\u0639\u0631\u064a\u0641 \u0627\u0644\u0623\u0646\u0627\u0642\u0629 \u0644\u0644\u062c\u064a\u0644 \u0627\u0644\u0631\u0642\u0645\u064a',
      hero_cta: '\u2190\u0639\u0631\u0636 \u0627\u0644\u0645\u062c\u0645\u0648\u0639\u0629\u00bb',
      cat_title: '\u0623\u0631\u0634\u064a\u0641 \u0631\u0642\u0645\u064a //',
      footer_follow: '\u062a\u0627\u0628\u0639\u0646\u0627',
      footer_contact: '\u062a\u0648\u0627\u0635\u0644 \u0645\u0639\u0646\u0627',
      footer_tawssil: '\u0627\u0644\u062a\u0648\u0635\u064a\u0644 (Zr Express)',
      footer_rights: '\u062c\u0645\u064a\u0639 \u0627\u0644\u062d\u0642\u0648\u0642 \u0645\u062d\u0641\u0648\u0638\u0629',
      footer_made: '\u0635\u0646\u0639 \u0641\u064a \u0627\u0644\u062c\u0632\u0627\u0626\u0631',
      view_products: '\u0639\u0631\u0636 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u2192',
      loading: '\u062c\u0627\u0631\u064a \u0627\u0644\u062a\u062d\u0645\u064a\u0644...',
      cart_title: '\u0633\u0644\u0629 \u0627\u0644\u062a\u0633\u0648\u0642',
      cart_empty: '\u0633\u0644\u062a\u0643 \u0641\u0627\u0631\u063a\u0629',
      cart_explore: '\u062a\u0635\u0641\u062d \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u2192',
      cart_subtotal: '\u0627\u0644\u0645\u062c\u0645\u0648\u0639 \u0627\u0644\u0641\u0631\u0639\u064a',
      cart_shipping: '\u0627\u0644\u0634\u062d\u0646',
      cart_total: '\u0627\u0644\u0645\u062c\u0645\u0648\u0639',
      cart_checkout: '\u0625\u062a\u0645\u0627\u0645 \u0627\u0644\u0634\u0631\u0627\u0621 \u2192',
      cart_continue: '\u2190 \u0645\u062a\u0627\u0628\u0639\u0629 \u0627\u0644\u062a\u0633\u0648\u0642',
      filter_all: '\u0627\u0644\u0643\u0644',
      sort_featured: '\u062a\u0631\u062a\u064a\u0628: \u0645\u0645\u064a\u0632',
      sort_price_asc: '\u0627\u0644\u0633\u0639\u0631: \u0645\u0646 \u0627\u0644\u0623\u0642\u0644 \u0644\u0644\u0623\u0639\u0644\u0649',
      sort_price_desc: '\u0627\u0644\u0633\u0639\u0631: \u0645\u0646 \u0627\u0644\u0623\u0639\u0644\u0649 \u0644\u0644\u0623\u0642\u0644',
      sort_newest: '\u0627\u0644\u0623\u062d\u062f\u062b \u0623\u0648\u0644\u0627\u064b',
      search_placeholder: '\u0627\u0628\u062d\u062b \u0639\u0646 \u0645\u0646\u062a\u062c\u0627\u062a...',
      no_products: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0646\u062a\u062c\u0627\u062a.',
      failed_load: '\u0641\u0634\u0644 \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a. \u0623\u0639\u064a\u062f \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629.',
      back_products: '\u2190 \u0627\u0644\u0639\u0648\u062f\u0629 \u0644\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
      color: '\u0627\u0644\u0644\u0648\u0646',
      size: '\u0627\u0644\u0645\u0642\u0627\u0633',
      size_chart: '\u062c\u062f\u0648\u0644 \u0627\u0644\u0645\u0642\u0627\u0633\u0627\u062a',
      quantity: '\u0627\u0644\u0643\u0645\u064a\u0629',
      add_cart: '\u0623\u0636\u0641 \u0644\u0644\u0633\u0644\u0629',
      nav_cart: '\u0627\u0644\u0633\u0644\u0629',
      checkout_title: '\u0625\u062a\u0645\u0627\u0645 \u0627\u0644\u0634\u0631\u0627\u0621',
      personal_info: '\u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0634\u062e\u0635\u064a\u0629',
      first_name: '\u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0623\u0648\u0644',
      last_name: '\u0627\u0633\u0645 \u0627\u0644\u0639\u0627\u0626\u0644\u0629',
      phone_number: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
      second_phone: '\u0631\u0642\u0645 \u062b\u0627\u0646\u064a',
      second_phone_optional: '(\u0625\u062e\u062a\u064a\u0627\u0631\u064a)',
      delivery_method: '\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
      step_delivery_type: '\u0627\u0644\u062e\u0637\u0648\u0629 1: \u0627\u062e\u062a\u0631 \u0646\u0648\u0639 \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
      step_delivery_service: '\u0627\u0644\u062e\u0637\u0648\u0629 2: \u0627\u062e\u062a\u0631 \u062e\u062f\u0645\u0629 \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
      step_delivery_info: '\u0627\u0644\u062e\u0637\u0648\u0629 3: \u0645\u0639\u0644\u0648\u0645\u0627\u062a \u0627\u0644\u062a\u0648\u0635\u064a\u0644',
      home_delivery: '\u062a\u0648\u0635\u064a\u0644 \u0644\u0644\u0628\u064a\u062a',
      home_delivery_desc: '\u062a\u0648\u0635\u064a\u0644 \u0644\u0628\u0627\u0628 \u062f\u0627\u0631\u0643',
      pickup_point: '\u0646\u0642\u0637\u0629 \u0627\u0633\u062a\u0644\u0627\u0645',
      pickup_desc: '\u0627\u0633\u062a\u0644\u0645 \u0645\u0646 \u0623\u0642\u0631\u0628 \u0646\u0642\u0637\u0629',
      home_address: '\u0627\u0644\u0639\u0646\u0648\u0627\u0646 \u0627\u0644\u062a\u0641\u0635\u064a\u0644\u064a',
      address_placeholder: '\u0627\u0633\u0645 \u0627\u0644\u0634\u0627\u0631\u0639\u060c \u0627\u0644\u0645\u0628\u0646\u0649...',
      order_notes: '\u0645\u0644\u0627\u062d\u0638\u0627\u062a \u0627\u0644\u0637\u0644\u0628',
      notes_optional: '(\u0625\u062e\u062a\u064a\u0627\u0631\u064a)',
      notes_placeholder: '\u062a\u0641\u0636\u064a\u0644\u0627\u062a \u0627\u0644\u062a\u0648\u0635\u064a\u0644...',
      order_summary: '\u0645\u0644\u0627\u062d\u0638\u0627\u062a \u0627\u0644\u0637\u0644\u0628',
      place_order: '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0637\u0644\u0628',
      terms: '\u0628\u0645\u0636\u064a \u0637\u0644\u0628\u0643\u060c \u0623\u0646\u062a \u062a\u0648\u0627\u0641\u0642 \u0639\u0644\u0649 \u0634\u0631\u0648\u0637 \u0627\u0644\u0633\u062a\u062e\u062f\u0627\u0645.',
      select_wilaya: '\u0627\u062e\u062a\u0631 \u0648\u0644\u0627\u064a\u0629',
      select_commune: '\u0627\u062e\u062a\u0631 \u0628\u0644\u062f\u064a\u0629',
      select_wilaya_first: '\u0627\u062e\u062a\u0631 \u0648\u0644\u0627\u064a\u0629 \u0623\u0648\u0644\u0627\u064b',
      commune: '\u0627\u0644\u0628\u0644\u062f\u064a\u0629',
      stop_desk: '\u0633\u062a\u0648\u0628 \u062f\u064a\u0633\u0643',
      empty_cart: '\u0633\u0644\u062a\u0643 \u0641\u0627\u0631\u063a\u0629.',
      explore_products: '\u062a\u0635\u0641\u062d \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a \u2192',
      product_not_found: '\u0627\u0644\u0645\u0646\u062a\u062c \u063a\u064a\u0631 \u0645\u0648\u062c\u0648\u062f.',
      related_products: '\u0645\u0646\u062a\u062c\u0627\u062a \u0634\u0628\u064a\u0647\u0629',
      in_stock: '\u0645\u062a\u0648\u0641\u0631',
      low_stock: '\u0645\u062e\u0632\u0648\u0646',
      out_of_stock: '\u0646\u0627\u0641\u0636 \u0627\u0644\u0645\u062e\u0632\u0648\u0646',
      size_chart_title: '\u062c\u062f\u0648\u0644 \u0627\u0644\u0645\u0642\u0627\u0633\u0627\u062a',
      cm: '\u0633\u0645',
      about_title: '\u0639\u0646 Celis clothing',
      about_p1: 'Celis clothing \u0647\u064a \u0639\u0644\u0627\u0645\u0629 \u0623\u0632\u064a\u0627\u0621 \u0648\u0644\u062f\u062a \u0641\u064a \u0627\u0644\u062c\u0632\u0627\u0626\u0631.',
      about_p2: '\u0646\u062c\u0645\u0639 \u0628\u064a\u0646 \u0627\u0644\u062c\u0645\u0627\u0644 \u0627\u0644\u0645\u0633\u062a\u0642\u0628\u0644 \u0648\u062b\u0642\u0627\u0641\u0629 \u0627\u0644\u0634\u0627\u0631\u0639.',
    },
    fr: {
      nav_home: 'Accueil',
      nav_products: 'Produits',
      hero_title: 'RENAISSANCE // \u00c8RE NUM\u00c9RIQUE',
      hero_subtitle: 'Red\u00e9finir le style pour la g\u00e9n\u00e9ration num\u00e9rique',
      hero_cta: '\u2192VOIR LA COLLECTION\u00bb',
      cat_title: 'archives num\u00e9riques //',
      footer_follow: 'Suivez-nous',
      footer_contact: 'Contact',
      footer_tawssil: 'Tawssil (Zr Express)',
      footer_rights: 'Tous droits r\u00e9serv\u00e9s',
      footer_made: 'Fabriqu\u00e9 en Alg\u00e9rie',
      view_products: 'VOIR LA COLLECTION \u2192',
      loading: 'Chargement...',
      cart_title: 'PANIER',
      cart_empty: 'Votre panier est vide',
      cart_explore: 'EXPLORER LES PRODUITS \u2192',
      cart_subtotal: 'SOUS-TOTAL',
      cart_shipping: 'LIVRAISON',
      cart_total: 'TOTAL',
      cart_checkout: 'PASSER COMMANDE \u2192',
      cart_continue: '\u2190 CONTINUER LES ACHATS',
      filter_all: 'Tout',
      sort_featured: 'Trier: En vedette',
      sort_price_asc: 'Prix: Croissant',
      sort_price_desc: 'Prix: D\u00e9croissant',
      sort_newest: 'Plus r\u00e9cent',
      search_placeholder: 'Rechercher...',
      no_products: 'Aucun produit trouv\u00e9.',
      failed_load: '\u00c9chec du chargement. R\u00e9essayez.',
      back_products: '\u2190 Retour aux produits',
      color: 'Couleur',
      size: 'Taille',
      size_chart: 'Guide des tailles',
      quantity: 'Quantit\u00e9',
      add_cart: 'AJOUTER AU PANIER',
      nav_cart: 'Panier',
      checkout_title: 'COMMANDE',
      personal_info: 'Informations personnelles',
      first_name: 'Pr\u00e9nom',
      last_name: 'Nom',
      phone_number: 'Num\u00e9ro de t\u00e9l\u00e9phone',
      second_phone: 'Deuxi\u00e8me t\u00e9l\u00e9phone',
      second_phone_optional: '(Optionnel)',
      delivery_method: 'Mode de livraison',
      step_delivery_type: '\u00c9tape 1: Type de livraison',
      step_delivery_service: '\u00c9tape 2: Service de livraison',
      step_delivery_info: '\u00c9tape 3: Infos de livraison',
      home_delivery: 'Livraison \u00e0 domicile',
      home_delivery_desc: 'Livr\u00e9 \u00e0 votre porte',
      pickup_point: 'Point relais',
      pickup_desc: 'R\u00e9cup\u00e9rer au point',
      home_address: 'Adresse d\u00e9taill\u00e9e',
      address_placeholder: 'Nom de rue, b\u00e2timent, etc...',
      order_notes: 'Notes de commande',
      notes_optional: '(Optionnel)',
      notes_placeholder: 'Pr\u00e9f\u00e9rences de livraison...',
      order_summary: 'R\u00c9CAPITULATIF',
      place_order: 'PASSER COMMANDE',
      terms: 'En passant votre commande, vous acceptez nos conditions g\u00e9n\u00e9rales.',
      select_wilaya: 'Choisir la wilaya',
      select_commune: 'Choisir la commune',
      select_wilaya_first: 'Choisir la wilaya d\'abord',
      commune: 'Commune',
      stop_desk: 'Stop Desk',
      empty_cart: 'Votre panier est vide.',
      explore_products: 'EXPLORER LES PRODUITS \u2192',
      product_not_found: 'Produit non trouv\u00e9.',
      related_products: 'Produits similaires',
      in_stock: 'En stock',
      low_stock: 'Stock faible',
      out_of_stock: 'Rupture de stock',
      size_chart_title: 'GUIDE DES TAILLES',
      cm: 'cm',
      about_title: '\u00c0 propos de Celis clothing',
      about_p1: 'Celis clothing est une marque de mode n\u00e9e en Alg\u00e9rie.',
      about_p2: 'Nous m\u00e9langeons esth\u00e9tique r\u00e9tro-futuriste et culture street.',
    }
  },
  t: function(key) {
    return this.translations[this.currentLang][key] || this.translations['en'][key] || key;
  },
  setLang: function(lang) {
    this.currentLang = lang;
    localStorage.setItem('yun_lang', lang);
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    this.applyTranslations();
  },
  applyTranslations: function() {
    var self = this;
    document.querySelectorAll('[data-i18n]').forEach(function(el) {
      var key = el.getAttribute('data-i18n');
      var translated = self.t(key);
      if (translated) el.textContent = translated;
    });
    document.querySelectorAll('[data-i18n-placeholder]').forEach(function(el) {
      var key = el.getAttribute('data-i18n-placeholder');
      var translated = self.t(key);
      if (translated) el.placeholder = translated;
    });
  },
  switchLang: function(lang) {
    var curtain = document.getElementById('lang-curtain');
    if (!curtain) {
      curtain = document.createElement('div');
      curtain.id = 'lang-curtain';
      curtain.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:#0a0a0a;z-index:999999;display:flex;align-items:center;justify-content:center;opacity:0;pointer-events:none;transition:opacity 0.3s ease';
      curtain.innerHTML = '<span style="font-family:Cormorant Garamond,serif;font-size:3rem;font-weight:300;color:white;letter-spacing:0.4em;opacity:0;transition:opacity 0.3s ease">Celis clothing</span>';
      document.body.appendChild(curtain);
    }
    curtain.style.pointerEvents = 'all';
    curtain.style.opacity = '1';
    curtain.querySelector('span').style.opacity = '1';
    setTimeout(function() {
      localStorage.setItem('yun_lang', lang);
      window.location.reload();
    }, 400);
  },
  createSwitcher: function() {
    var current = this.currentLang;
    var langs = [
      { code: 'en', label: 'EN', flag: '\ud83c\uddec\ud83c\udde7' },
      { code: 'ar', label: 'AR', flag: '\ud83c\uddf8\ud83c\udde6' },
      { code: 'fr', label: 'FR', flag: '\ud83c\uddeb\ud83c\uddf7' }
    ];
    var html = '<div class="lang-switcher" style="position:relative;display:inline-block">';
    html += '<button class="lang-btn" onclick="event.stopPropagation();this.parentElement.querySelector(\'.lang-dropdown\').classList.toggle(\'open\')" aria-label="Change language" style="background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.15);border-radius:8px;padding:6px 12px;color:white;font-family:Space Mono,monospace;font-size:0.7rem;cursor:pointer;display:flex;align-items:center;gap:6px">';
    var activeLang = langs.find(function(l) { return l.code === current; }) || langs[0];
    html += '<span>' + activeLang.flag + '</span> ' + activeLang.label;
    html += '<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>';
    html += '</button>';
    html += '<div class="lang-dropdown" style="position:absolute;top:calc(100% + 4px);right:0;background:#1a1a1a;border:1px solid rgba(255,255,255,0.1);border-radius:8px;overflow:hidden;min-width:120px;display:none;z-index:9999">';
    langs.forEach(function(l) {
      var active = l.code === current ? 'background:rgba(255,255,255,0.1)' : '';
      html += '<button onclick="YUN_I18N.switchLang(\'' + l.code + '\')" style="display:flex;align-items:center;gap:8px;width:100%;padding:10px 14px;border:none;background:' + active + ';color:white;font-family:Inter,sans-serif;font-size:0.8rem;cursor:pointer;text-align:left">';
      html += '<span>' + l.flag + '</span> ' + l.label + ' <span style="color:rgba(255,255,255,0.3);font-size:0.7rem;margin-left:auto">' + (l.code === 'en' ? 'English' : l.code === 'ar' ? '\u0627\u0644\u0639\u0631\u0628\u064a\u0629' : 'Fran\u00e7ais') + '</span>';
      html += '</button>';
    });
    html += '</div></div>';
    return html;
  },
  init: function() {
    document.documentElement.lang = this.currentLang;
    document.documentElement.dir = this.currentLang === 'ar' ? 'rtl' : 'ltr';
    this.applyTranslations();
  }
};

document.addEventListener('click', function(e) {
  var dropdown = document.querySelector('.lang-dropdown');
  if (dropdown && !e.target.closest('.lang-switcher')) {
    dropdown.classList.remove('open');
  }
});

var langStyle = document.createElement('style');
langStyle.textContent = '.lang-dropdown.open { display: block !important; }';
document.head.appendChild(langStyle);
