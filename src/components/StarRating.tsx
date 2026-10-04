import { Star } from 'lucide-react';

type StarRatingProps = {
  value: number;
  onChange?: (rating: number) => void;
  size?: number;
  readOnly?: boolean;
};

export default function StarRating({
  value,
  onChange,
  size = 48,
  readOnly = false,
}: StarRatingProps) {
  return (
    <div className="flex flex-nowrap items-center gap-1.5 whitespace-nowrap">
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          type="button"
          disabled={readOnly}
          onClick={() => onChange?.(star)}
          className={`shrink-0 transition-all duration-200 ${
            readOnly ? 'cursor-default' : 'hover:scale-110 active:scale-95'
          }`}
          aria-label={`${star} star${star > 1 ? 's' : ''}`}
        >
          <Star
            size={size}
            className={
              star <= value
                ? 'fill-amber-400 text-amber-400 drop-shadow-sm'
                : 'fill-gray-200 text-gray-300'
            }
          />
        </button>
      ))}
    </div>
  );
}
