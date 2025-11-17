interface SearchIconProps {
  color?: string;
  size?: number;
  className?: string;
}

const SearchIcon = ({ color = 'currentColor', size = 24, className = '' }: SearchIconProps) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke={color}
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    className={className}
  >
    <path d="m21 21-4.34-4.34" />
    <circle cx="11" cy="11" r="8" />
  </svg>
);

export default SearchIcon;
