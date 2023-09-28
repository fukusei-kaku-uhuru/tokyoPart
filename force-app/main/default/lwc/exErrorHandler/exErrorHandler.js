import { showToast } from 'c/exShowToast';

/**
 * エラー時処理を汎用的に行う
 */
const errorHandle = (error) => {

	console.error(error);

	const toast = showToast('予期せぬエラーが発生しました。', '', 'error');
	return toast;
}

export { errorHandle }