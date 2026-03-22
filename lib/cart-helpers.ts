import { cookies } from 'next/headers'
import { createCart, getCart, ShopifyCart } from './shopify'

const CART_COOKIE = 'shopify_cart_id'

export async function getOrCreateCart(): Promise<ShopifyCart> {
  const cookieStore = cookies()
  const cartId = cookieStore.get(CART_COOKIE)?.value

  if (cartId) {
    const cart = await getCart(cartId)
    if (cart) return cart
  }

  const newCart = await createCart()
  return newCart
}

export function getCartCookieName() {
  return CART_COOKIE
}
